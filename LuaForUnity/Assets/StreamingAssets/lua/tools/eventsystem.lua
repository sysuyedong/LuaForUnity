--利用ID分离对EventSystem的直接引用
EventSystem = EventSystem or BaseClass()


--事件系统(非单健)
function EventSystem:__init()
	--需要激发的事件(延后调用方式)
	self.need_fire_events = List.New()

	--事件列表
	self.event_list = {}

	self.delay_handle_list = {}

	self.delay_id_count = 0

	self.is_deleted = false
	
	self.timer_quest_manager = nil  	-- TimerQuest()

	self.imm_dmp_list = {}		-- 立即触发事件的监听器
	self.nf_dmp_list = {}		-- 下一帧触发事件的监听器

	self.error_callback = nil
end

function EventSystem:SetErrorCallback(callback)
	self.error_callback = callback
end
		
function EventSystem:CallError(event_id)
	if self.error_callback then
		local str = "death loop:" .. event_id
		self.error_callback(str)
	end
end

--调用已经处于派发队列中的Event
function EventSystem:Update()
	--timer quest
	if self.timer_quest_manager ~= nil then
		self.timer_quest_manager:Update(Status.NowTime, Status.ElapseTime)
	end

	--依次执行所有需要触发的事件
	while not List.Empty(self.need_fire_events) do
		local fire_info = List.PopFront(self.need_fire_events)
		local event_id = fire_info.event:GetEventID()

		local info = self.nf_dmp_list[event_id]
		if info == nil then
			info = {frame=Status.NowFrame, n=1}
			self.nf_dmp_list[event_id] = info
		else
			if info.frame ~= Status.NowFrame then
				info.frame = Status.NowFrame
				info.n = 1
			else
				info.n = info.n + 1
			end
		end

		if info.n > 1000 then
			self:CallError(event_id)
			return
		end

		fire_info.event:Fire(fire_info.arg_list)
	end
end

function EventSystem:Bind(event_id, event_func)
	if event_id == nil then
		error("Try to bind to a nil event_id")
		return
	end
	
	if event_func == nil then
		error("Try to bind to a nil event_func")
		return
	end

	if self.is_deleted then
		return
	end

	if self.event_list[event_id] == nil then
		self:CreateEvent(event_id)
	end
	local tmp_event = self.event_list[event_id]
	
	return tmp_event:Bind(event_func)
end

function EventSystem:UnBind(event_handle)
	if event_handle == nil or event_handle.event_id == nil then
		return
	end

	if self.is_deleted then
		return
	end

	local tmp_event = self.event_list[event_handle.event_id]
	if tmp_event ~= nil then
		tmp_event:UnBind(event_handle)
	end
end

function EventSystem:UnBindAll()
	self.event_list = {}
end

--立即触发
function EventSystem:Fire(event_id, ...)
	if event_id == nil then
		error("Try to call EventSystem:Fire() with a nil event_id")
		return
	end

	if self.is_deleted then
		return
	end

	local info = self.imm_dmp_list[event_id]
	if info == nil then
		info = {frame = Status.NowFrame, n = 1}
		self.imm_dmp_list[event_id] = info
	else
		if info.frame ~= Status.NowFrame then
			info.frame = Status.NowFrame
			info.n = 1
		else
			info.n = info.n + 1
		end
	end

	-- if self == RoleManager.Instance.mainRoleInfo.eventSys then
	-- 	print("= = =主角Fire:", event_id, info.n, Status.NowFrame)
	-- end
	if info.n > 1000 then
		self:CallError(event_id)
		return
	end

	local tmp_event = self.event_list[event_id] 
	if tmp_event ~= nil then
		tmp_event:Fire({...})
	end
end

--下一帧触发
function EventSystem:FireNextFrame(event_id, ...)
	if event_id == nil then
		error("Try to call EventSystem:FireNextFrame() with a nil event_id")
		return
	end

	if self.is_deleted then
		return
	end

	local tmp_event = self.event_list[event_id] 
	if tmp_event ~= nil then
		local fire_info = {}
		fire_info.event = tmp_event
		fire_info.arg_list = {...}
		List.PushBack(self.need_fire_events, fire_info)
	end
end

function EventSystem:FireDelay(event_id, delay_time, ...)
	print("use fire delay")
	if event_id == nil then
		error("Try to call EventSystem:FireDelay() with a nil event_id")
		return
	end

	if self.timer_quest_manager == nil then
		self.timer_quest_manager = TimerQuest()
	end

	self.delay_id_count = self.delay_id_count + 1
	local delay_id = self.delay_id_count
	local system_id = self.system_id
	local arg_list = {...}
	local delay_call_func = function()
		--print("delay func")
		obj:Fire(event_id, unpack(arg_list))	--执行定时任务
		obj.delay_handle_list[delay_id] = nil	--删除该句柄
	end
	local quest_handle = self.timer_quest_manager:AddDelayQuest(delay_call_func, delay_time)
	self.delay_handle_list[delay_id] = quest_handle
end

function EventSystem:CreateEvent(event_id)
	self.event_list[event_id] = Event.New(event_id, self)
end

function EventSystem:__delete()
	--self.timer_quest_manager:Stop()
	self.timer_quest_manager = nil	
end


