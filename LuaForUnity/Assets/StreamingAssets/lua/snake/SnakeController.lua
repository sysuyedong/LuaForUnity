require("Assets.StreamingAssets.lua.snake.SnakeModel")
require("Assets.StreamingAssets.lua.snake.SnakeObj")
require("Assets.StreamingAssets.lua.snake.Scene")
require("Assets.StreamingAssets.lua.snake.Food")
require("Assets.StreamingAssets.lua.snake.Obstacle")

SnakeController = SnakeController or BaseClass()

function SnakeController:__init( ... )
	self.model = SnakeModel:getInstance()
end

function SnakeController:__delete( ... )

end

function SnakeController:Update(now_time, elapse_time)
	self.model:Update(now_time, elapse_time)
end