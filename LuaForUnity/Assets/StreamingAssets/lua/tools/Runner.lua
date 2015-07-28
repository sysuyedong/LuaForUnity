--[[@------------------------------------------------------------------
说明: 根据外部设定的优先级在每一帧中依次执行所有托管的RunObj
作者: deadline
----------------------------------------------------------------------]]
Runner = Runner or BaseClass()

function Runner:__init(  )
	Runner.Instance = self
	self.all_run_obj_list = {}		--用于标记某个模块是否已经注册,避免重复性的注册
	self.id_count = 0

	--支持1 ~ 16级优先级指定, 1为最先执行, 16为最后执行
	self.priority_run_obj_list = {}
	for i=1,16 do
		table.insert(self.priority_run_obj_list, {})
	end
end

--[[@
功能:	主Update中调用该方法,触发托管对象的Update
参数:	
		无
返回值:
		无
其它:	无
作者:	deadline
]]
function Runner:Update( now_time, elapse_time )
	for i=1,16 do
		local priority_tbl = self.priority_run_obj_list[i]
		for _, v in pairs(priority_tbl) do
			v:Update(now_time, elapse_time)
		end
	end
end

--[[@
功能:	向Runner添加一个RunObj, RunObj必须存在Update方法
参数:	
		run_obj 要添加的run_obj对象 any 必须实现Update方法
		priority_level Update优先级 1-16,数字越小越先执行
返回值:
		是否添加run_obj成功 bool run_obj如果已经存在于Runner中, 则不能再添加
其它:	无
作者:	deadline
]]
function Runner:AddRunObj( run_obj , priority_level )
	local obj = self.all_run_obj_list[run_obj]
	if obj ~= nil then
		--已经存在该对象, 不重复添加
		return false
	else
		if run_obj["Update"] == nil then
			error("Runner:AddRunObj try to add a obj not have Update method!")
		end

		--对象不存在,正常添加
		self.id_count = self.id_count + 1
		priority_level = priority_level or 16
		self.all_run_obj_list[run_obj] = {priority_level, self.id_count}
		self.priority_run_obj_list[priority_level][self.id_count] = run_obj
	end
end

--[[@
功能:	从Runner中删除一个run_obj
参数:	
		run_obj
返回值:
		无
其它:	无
作者:	deadline
]]
function Runner:RemoveRunObj( run_obj )
	local key_info = self.all_run_obj_list[run_obj]
	if key_info ~= nil then
		self.all_run_obj_list[run_obj] = nil
		self.priority_run_obj_list[key_info[1]][key_info[2]] = nil
	end
end