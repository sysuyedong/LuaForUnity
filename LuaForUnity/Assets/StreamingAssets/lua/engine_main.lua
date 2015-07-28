luanet.load_assembly("UnityEngine")
Time = luanet.import_type("UnityEngine.Time")
GameObject = luanet.import_type("UnityEngine.GameObject")
Vector3 = luanet.import_type("UnityEngine.Vector3")
PrimitiveType = luanet.import_type("UnityEngine.PrimitiveType")

require("Assets.StreamingAssets.lua.tools.require_tools")
require("Assets.StreamingAssets.lua.snake.SnakeController")

RunnerPriority = {
	Controller = 2,
}

runner = Runner.New()
snake_controller = SnakeController.New()

function Start()
	print("Lua engine start!")
	runner:AddRunObj(snake_controller, RunnerPriority.Controller)
end

function Update()
	runner:Update(Time.time, Time.deltaTime)
end

function OnDestroy()
	print("Lua engine destroy!")
end