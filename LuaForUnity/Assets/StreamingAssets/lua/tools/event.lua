--用于唯一标识obj的table

_inner_event_connection_obj = _inner_event_connection_obj or {}

Event = Event or BaseClass()

function Event:__init(event_id, parent)
	self.parent = parent
	self.event_id = event_id
	self.bind_id_count = 0
	self.bind_count = 0
	self.event_func_list = {}
end

function Event:GetEventID()
	return self.event_id
end

function Event:Fire(arg_table)
	--[[
	local arg_count = table.maxn(arg_table) or 0
	local myunpack
	myunpack = function (t, i)
		if i <= arg_count then
			return t[i], myunpack(t, i + 1)
		end
	end
	]]

	for _, func in pairs(self.event_func_list) do
		func( unpack( arg_table ) )
	end
end

function Event:UnBind(obj)
	--仅当obj符合类型时才作对应操作
	if getmetatable(obj) == _inner_event_connection_obj and obj.event_id == self.event_id then
		self.event_func_list[obj.bind_id] = nil
		self.bind_count = self.bind_count - 1
	end
end

function Event:Bind(event_func)
	
	local obj = {}
	setmetatable(obj, _inner_event_connection_obj)

	self.bind_count = self.bind_count + 1
	if self.bind_count > 5000 then
		obj.event_id = self.event_id
		obj.bind_id = 0

		self.parent:CallError(self.event_id)
		return obj
	end

	self.bind_id_count = self.bind_id_count + 1
	obj.event_id = self.event_id
	obj.bind_id = self.bind_id_count
	self.event_func_list[obj.bind_id] = event_func
	return obj
end
