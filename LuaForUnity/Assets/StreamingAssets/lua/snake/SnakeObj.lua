SnakeObj = SnakeObj or BaseClass()

function SnakeObj:__init(pos)
	self.head = GameObject.CreatePrimitive(PrimitiveType.Cube)
	self.head.transform.position = pos
	self.body = {}
	self.dir = 6

	self.start_time = Time.time
	local b = GameObject.CreatePrimitive(PrimitiveType.Cube)
	b.transform.position = Vector3(pos.x - 1, 0, pos.z)
	table.insert(self.body, b)
end

function SnakeObj:__delete( ... )
	if self.head then
		GameObject.Destroy(self.head)
	end

	for k, v in ipairs(self.body) do
		GameObject.Destroy(v)
	end
	self.body = {}
end

function SnakeObj:Update(now_time, elapse_time)
	if now_time - self.start_time >= 1 then
		local pos = self.head.transform.position
		self:Move(pos.x + 1, pos.z)
		self.start_time = now_time
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
		self.head.transform.position = Vector3(x, 0, y)
	elseif grid_type == SceneGridType.Obstacle then
	elseif grid_type == SceneGridType.Food then
	elseif grid_type == SceneGridType.Snake then
	end
end