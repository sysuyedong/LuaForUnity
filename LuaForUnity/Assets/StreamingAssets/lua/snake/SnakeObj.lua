SnakeObj = SnakeObj or BaseClass()

function SnakeObj:__init(key, pos)
	self.key = key
	self.head = self:GenObj(pos)
	self.body = {}
	self.dir = 6
	self.move_speed = 2

	self.start_time = Time.time
	local b = self:GenObj(Vector3(pos.x - 1, 0, pos.z))
	table.insert(self.body, b)
	-- b = self:GenObj(Vector3(pos.x - 2, 0, pos.z))
	-- table.insert(self.body, b)
	-- b = self:GenObj(Vector3(pos.x - 3, 0, pos.z))
	-- table.insert(self.body, b)
end

function SnakeObj:__delete( ... )
	if self.head then
		self:DestroyObj(self.head)
	end

	for k, v in ipairs(self.body) do
		self:DestroyObj(v)
	end
	self.body = {}
end

function SnakeObj:DestroyObj(obj)
	local pos = obj.transform.position
	SnakeModel.Instance.scene:SetMap(pos.x, pos.z, SceneGridType.Empty)
	GameObject.Destroy(obj)
end

function SnakeObj:GenObj(pos)
	local obj = GameObject.CreatePrimitive(PrimitiveType.Cube)
	obj.transform.position = pos
	SnakeModel.Instance.scene:SetMap(pos.x, pos.z, SceneGridType.Snake)
	return obj
end

function SnakeObj:SetObjPositon(obj, pos)
	local old_pos = obj.transform.position
	SnakeModel.Instance.scene:SetMap(old_pos.x, old_pos.z, SceneGridType.Empty)
	obj.transform.position = pos
	SnakeModel.Instance.scene:SetMap(pos.x, pos.z, SceneGridType.Snake)
end

function SnakeObj:Update(now_time, elapse_time)
	if now_time - self.start_time >= 1 / self.move_speed then
		local pos = self.head.transform.position
		local offset_x = 0
		local offset_y = 0
		if self.dir == 4 then
			offset_x = -1
		elseif self.dir == 6 then
			offset_x = 1
		elseif self.dir == 8 then
			offset_y = 1
		elseif self.dir == 2 then
			offset_y = -1
		end
		self:Move(pos.x + offset_x, pos.z + offset_y)
		self.start_time = now_time
	end

	if Input.anyKey then
		if Input.GetKey(KeyCode.W) then
			self.dir = 8
		end
		if Input.GetKey(KeyCode.S) then
			self.dir = 2
		end
		if Input.GetKey(KeyCode.A) then
			self.dir = 4
		end
		if Input.GetKey(KeyCode.D) then
			self.dir = 6
		end
	end
end

function SnakeObj:GetTail()
	local tail
	if #self.body == 0 then
		tail = self.head
	else
		tail = table.remove(self.body)
	end
	return tail
end

function SnakeObj:Move(x, y)
	local grid_type = SnakeModel.Instance.scene:GetMap(x, y)
	if grid_type == SceneGridType.Empty then
		-- replace head and tail
		local tail = self:GetTail()
		table.insert(self.body, 1, self.head)
		self.head = tail
		self:SetObjPositon(self.head, Vector3(x, 0, y))
	elseif grid_type == SceneGridType.Obstacle or grid_type == SceneGridType.Snake then
		-- die
		SnakeModel.Instance:Fire(SnakeEvent.REMOVE_SNAKE, self.key)
	elseif grid_type == SceneGridType.Food then
		-- replace head by tail and grow new tail
		local tail = self:GetTail()
		local old_pos = tail.transform.position
		table.insert(self.body, 1, self.head)
		self.head = tail
		self:SetObjPositon(self.head, Vector3(x, 0, y))
		local new_tail = self:GenObj(old_pos)
		table.insert(self.body, new_tail)
		-- remove food
		SnakeModel.Instance:Fire(SnakeEvent.REMOVE_FOOD, x, y)
	end
end