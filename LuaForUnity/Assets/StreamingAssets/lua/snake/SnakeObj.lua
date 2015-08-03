SnakeObj = SnakeObj or BaseClass()

SnakeObjDir = {
	Left = -1,
	Right = 1,
	Up = 2,
	Down = -2,
}

function SnakeObj:__init(key, pos)
	self.key = key
	self.head = self:GenObj(pos)
	self.body = {}
	self.dir = SnakeObjDir.Right
	self.move_speed = 40
	self.prepare_turn = false
	self.path = nil

	self.start_time = Time.time
	-- local b = self:GenObj(Vector3(pos.x - 1, 0, pos.z))
	-- table.insert(self.body, b)
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
		if self.dir == SnakeObjDir.Left then
			offset_x = -1
		elseif self.dir == SnakeObjDir.Right then
			offset_x = 1
		elseif self.dir == SnakeObjDir.Up then
			offset_y = 1
		elseif self.dir == SnakeObjDir.Down then
			offset_y = -1
		end
		-- self:Move(pos.x + offset_x, pos.z + offset_y)
		self:AutoMove()
		self.start_time = now_time
	end

	if Input.anyKey then
		if Input.GetKey(KeyCode.W) then
			self:ChangeDir(SnakeObjDir.Up)
		end
		if Input.GetKey(KeyCode.S) then
			self:ChangeDir(SnakeObjDir.Down)
		end
		if Input.GetKey(KeyCode.A) then
			self:ChangeDir(SnakeObjDir.Left)
		end
		if Input.GetKey(KeyCode.D) then
			self:ChangeDir(SnakeObjDir.Right)
		end
	end
end

function SnakeObj:ChangeDir(dir)
	-- Todo: avoid changing dir to fast
	if self.dir ~= -dir and not self.prepare_turn then
		self.dir = dir
		self.prepare_turn = true
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
	self.prepare_turn = false
end

function SnakeObj:AutoMove()
	-- find path first if path not exist
	if self.path == nil or #self.path == 0 then
		PathFinding.Instance:SetData(SnakeModel.Instance.scene.map, SnakeModel.Instance.scene.width, SnakeModel.Instance.scene.height)
		local food = SnakeModel.Instance.scene:GetNearestFood(self.head.transform.position)
		self.path = PathFinding.Instance:FindPath(self.head.transform.position, food:GetPosition())
		table.remove(self.path, 1)
	end
	-- pop path and do move
	if self.path and #self.path > 0 then
		local v = table.remove(self.path, 1)
		self:Move(v.x, v.z)
	end
end