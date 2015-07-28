
--保存类类型的虚表
_in_vtbl_map = _in_vtbl_map or {}
_in_ctype_map = _in_ctype_map or {}
_in_ctype_count = _in_ctype_count or 0
_in_obj_ins_id = _in_obj_ins_id or 0

--for debug mem
_in_obj_ins_map = _in_obj_ins_map or {}
_in_obj_count_map = _in_obj_count_map or {}



function BaseClass(super)
	-- 生成一个类类型
	local class_type = {}
	-- 在创建对象的时候自动调用
	class_type.__init = false
	class_type.__delete = false

	_in_ctype_count = _in_ctype_count + 1
	class_type._id = _in_ctype_count
	class_type._pid = super and super._id or 0
	_in_ctype_map[_in_ctype_count] = class_type

	local cls_obj_ins_map = {}
	_in_obj_ins_map[class_type] = cls_obj_ins_map
	setmetatable(cls_obj_ins_map, {__mode = "\"v\""})

	_in_obj_count_map[class_type] = 0

	local info = debug.getinfo(2, "Sl")
	class_type._source = info.source
	class_type._cline = info.currentline
	class_type.__is_cc_type = true
	class_type.super = super
	class_type.New = function(...)
		-- 生成一个类对象
		_in_obj_ins_id = _in_obj_ins_id + 1
		local obj = {}
		obj._class_type = class_type
		obj._cid = class_type._id
		obj._iid = _in_obj_ins_id
		obj._use_delete_method = false
		cls_obj_ins_map[_in_obj_ins_id] = obj --save here for mem debug
		_in_obj_count_map[class_type] = _in_obj_count_map[class_type] + 1

		-- 在初始化之前注册基类方法
		setmetatable(obj, { __index = _in_vtbl_map[class_type]
							,
							__is_co_meta = true
							,
							__tostring = function(t)
								return string.format("lua_object[id:%d,cid:%d,del:%d,%s[%d]]", t._iid, t._cid, t._use_delete_method and 1 or 0, class_type._source, class_type._cline)
							end
							})

		-- 调用初始化方法
		do
			local create 
			create = function(c, ...)
				if c.super then
					create(c.super, ...)
				end
				if c.__init then
					c.__init(obj, ...)
				end
			end

			create(class_type, ...)
		end

		-- 注册一个delete方法
		obj.DeleteMe = function(self)
			if self._use_delete_method then
				return
			end

			local now_super = self._class_type 
			while now_super ~= nil do	
				if now_super.__delete then
					now_super.__delete(self)
				end
				now_super = now_super.super
			end
			self._use_delete_method = true;
		end

		return obj
	end

	local vtbl = {}
	_in_vtbl_map[class_type] = vtbl
 
	setmetatable(class_type, {__newindex =
		function(t,k,v)
			vtbl[k] = v
		end
		, 
		__index = vtbl --For call parent method
		, 
		__call = function( t, ... )
			class_type.New(...)	
		end
		,
	})
 
	if super then
		setmetatable(vtbl, {__index =
			function(t,k)
				local ret = _in_vtbl_map[super][k]
				--do not do accept, make hot update work right!
				vtbl[k] = ret
				return ret
			end
		})
	end
 
	return class_type
end


