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
	self.food_id = 0
	self.snake_id = 0
	self.map = {}
	self:GenerateMap()

	self.start_time = Time.time
	self:AddSnake("snake", Vector3(5, 0, 5))
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
				self:SetMap(w, h, SceneGridType.Obstacle)
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
	local snake = SnakeObj.New(pos)
	self.snake_list[key] = snake
end

function Scene:AddFood(food_type)
	self.food_id = self.food_id + 1
	local food = Food.New(food_type, self.food_id)
	self.food_list[self.food_id] = food
	self:SetMap(food.x, food.y, SceneGridType.Food)
end

function Scene:RemoveFood(id)
	local food = self.food_list[id]
	if food then
		food:DeleteMe()
		food = nil
	end
end

function Scene:GetRandomEmptyPositionIndex()
	math.randomseed(os.time())
	-- Todo: more effective way to get a random position
	repeat
		x = math.random(1, self.width - 2)
		y = math.random(1, self.height - 2)
	until self:GetMap(x, y) ~= SceneGridType.Empty
	return x, y
end

function Scene:GetRandomEmptyPosition()
	local x, y = self:GetRandomEmptyPositionIndex()
	return Vector3(x, 0, y)
end