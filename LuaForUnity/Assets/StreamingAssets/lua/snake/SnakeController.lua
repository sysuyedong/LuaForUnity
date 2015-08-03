require("Assets.StreamingAssets.lua.snake.SnakeModel")
require("Assets.StreamingAssets.lua.snake.SnakeEvent")
require("Assets.StreamingAssets.lua.snake.SnakeObj")
require("Assets.StreamingAssets.lua.snake.Scene")
require("Assets.StreamingAssets.lua.snake.Food")
require("Assets.StreamingAssets.lua.snake.Obstacle")
require("Assets.StreamingAssets.lua.snake.PathFinding")

SnakeController = SnakeController or BaseClass()

function SnakeController:__init( ... )
	self.model = SnakeModel:getInstance()
	self.path_finding = PathFinding:getInstance()
	self:AddEvents()
end

function SnakeController:__delete( ... )

end

function SnakeController:Update(now_time, elapse_time)
	self.model:Update(now_time, elapse_time)
end

function SnakeController:AddEvents()
	local function on_remove_snake(key)
		self.model.scene:RemoveSnake(key)
	end
	self.model:Bind(SnakeEvent.REMOVE_SNAKE, on_remove_snake)

	local function on_remove_food(x, y)
		self.model.scene:RemoveFoodByPos(x, y)
		self.model.scene:AddFood()
	end
	self.model:Bind(SnakeEvent.REMOVE_FOOD, on_remove_food)
end