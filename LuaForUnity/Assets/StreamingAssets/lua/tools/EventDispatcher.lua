--用于唯一标识obj的table

EventDispatcher = EventDispatcher or BaseClass()
function EventDispatcher:__init()

	local error_callback = function(str)
		GameError.Instance:OnEventError(str)
	end

	self.eventSys = EventSystem.New()
	self.eventSys:SetErrorCallback(error_callback)
end

function EventDispatcher:Bind(type_str, listener_func)
	return self.eventSys:Bind(type_str,listener_func);
end
function EventDispatcher:UnBind(obj)
	self.eventSys:UnBind(obj);
end
function EventDispatcher:UnBindAll()
	self.eventSys:UnBindAll()
end
function EventDispatcher:Fire(type_str, ...)
	self.eventSys:Fire(type_str, ...)
end
