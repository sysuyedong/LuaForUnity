Scene = Scene or BaseClass()

SceneGridType = {
	Empty = 1,
	Obstacle = 2,
	Snake = 3,
	Food = 4,
}

function Scene:__init(width, height)
	self.width = width
	self.height = height
	self.wall_list = {}
	self.food_list = {}
	self.snake_list = {}
	self.obstacle_list = {}
	self.food_id = 0
	self.snake_id = 0
	self.map = {}

	self.begin_delay = 2
	self.begin = false
	self.start_time = Time.time
end

function Scene:__delete( ... )
	self:RemoveMap()
end

function Scene:RemoveMap()
	for k, v in ipairs(self.wall_list) do
		v:DeleteMe()
		self:SetMap(v.x, v.y, SceneGridType.Empty)
	end
	self.wall_list = {}
end

function Scene:Update(now_time, elapse_time)
	for k, v in pairs(self.snake_list) do
		v:Update(now_time, elapse_time)
	end

	if not self.begin and now_time - self.start_time > self.begin_delay then
		self.begin = true
		self:GenerateMap()
		self:AddSnake("snake", Vector3(6, 0, 5))
		self:AddFood(nil, 9, 5)
		for k = 0, 20 do
			self:AddObstacle(k, 10)
		end
		for k = 10, 35 do
			self:AddObstacle(k, 20)
		end
		for k = 5, 15 do
			self:AddObstacle(k, 28)
		end
		for k = 35, 46 do
			self:AddObstacle(k, 33)
		end
		for k = 2, 10 do
			self:AddObstacle(k, 45)
		end
	end
end

function Scene:GenerateMap()
	self:RemoveMap()

	local width = self.width - 1
	local height = self.height - 1
	for h = 0, height do
		for w = 0, width do
			if w == 0 or w == width or h == 0 or h == height then
				local obstacle = Obstacle.New()
				obstacle:SetPosition(w, h)
				table.insert(self.wall_list, obstacle)
			else
				self:SetMap(w, h, SceneGridType.Empty)
			end
		end
	end
end

function Scene:IsPosValid(x, y)
	return x >= 0 and x <= self.width - 1 and y >= 0 and y <= self.height - 1
end

function Scene:GetMap(x, y)
	if self:IsPosValid(x, y) then
		local index = y * self.width + x
		return self.map[index]
	end
end

function Scene:SetMap(x, y, grid_type)
	if self:IsPosValid(x, y) then
		local index = y * self.width + x
		self.map[index] = grid_type
	end
end

function Scene:AddSnake(key, pos)
	if self.snake_list[key] then
		return
	end
	local snake = SnakeObj.New(key, pos)
	self.snake_list[key] = snake
end

function Scene:RemoveSnake(key)
	local snake = self.snake_list[key]
	if snake then
		snake:DeleteMe()
		self.snake_list[key] = nil
	end
end

function Scene:AddFood(food_type, x, y)
	self.food_id = self.food_id + 1
	local food = Food.New(food_type, self.food_id)
	if x == nil or y == nil then
		x, y = self:GetRandomEmptyPositionIndex()
	end
	print("Add Food: " .. x .. ", " .. y)
	food:SetPosition(x, y)
	self.food_list[self.food_id] = food
end

function Scene:RemoveFood(id)
	local food = self.food_list[id]
	if food then
		food:DeleteMe()
		self.food_list[id] = nil
	end
end

function Scene:RemoveFoodByPos(x, y)
	for k, v in pairs(self.food_list) do
		if v.x == x and v.y == y then
			v:DeleteMe()
			self.food_list[k] = nil
			break
		end
	end
end

function Scene:GetNearestFood(pos)
	local min = nil
	local index = nil
	for k, v in pairs(self.food_list) do
		local food_pos = v:GetPosition()
		local manhatton_dis = math.abs(food_pos.x - pos.x) + math.abs(food_pos.z - pos.z)
		if min == nil then
			min = manhatton_dis
			index = k
		end
		if manhatton_dis < min then
			min = manhatton_dis
			index = k
		end
	end
	if index ~= nil then
		return self.food_list[index]
	end
end

function Scene:AddObstacle(x, y)
	local obstacle = Obstacle.New()
	obstacle:SetPosition(x, y)
	self.obstacle_list[y * self.width + x] = obstacle
end

function Scene:RemoveObstacle(x, y)
	local obstacle = self.obstacle_list[y * self.width + x]
	if obstacle then
		obstacle:DeleteMe()
		self.obstacle_list[y * self.width + x] = nil
	end
end

function Scene:GetRandomEmptyPositionIndex()
	math.randomseed(os.time())
	-- Todo: more effective way to get a random position
	repeat
		x = math.random(1, self.width - 2)
		y = math.random(1, self.height - 2)
	until self:GetMap(x, y) == SceneGridType.Empty
	return x, y
end

function Scene:GetRandomEmptyPosition()
	local x, y = self:GetRandomEmptyPositionIndex()
	return Vector3(x, 0, y)
end