SnakeModel = SnakeModel or BaseClass(BaseModel)

function SnakeModel:__init()
	SnakeModel.Instance = self

	self.scene = Scene.New(50, 50)
end

function SnakeModel:getInstance()
	if SnakeModel.Instance == nil then
		SnakeModel.New()
	end
	return SnakeModel.Instance
end

function SnakeModel:Update(now_time, elapse_time)
	self.scene:Update(now_time, elapse_time)
end