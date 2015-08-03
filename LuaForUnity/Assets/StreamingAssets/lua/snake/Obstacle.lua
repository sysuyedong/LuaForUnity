Obstacle = Obstacle or BaseClass()

function Obstacle:__init()
	self.obj = nil
	self.x = 0
	self.y = 0

	self:Create()
end

function Obstacle:__delete( ... )
	if self.obj then
		self:DestroyObj(self.obj)
	end
end

function Obstacle:DestroyObj(obj)
	local pos = obj.transform.position
	SnakeModel.Instance.scene:SetMap(pos.x, pos.z, SceneGridType.Empty)
	GameObject.Destroy(obj)
end

function Obstacle:Create()
	self.obj = GameObject.CreatePrimitive(PrimitiveType.Cube)
end

function Obstacle:SetPosition(x, y)
	self.x = x
	self.y = y
	self.obj.transform.position = Vector3(x, 0, y)
	SnakeModel.Instance.scene:SetMap(x, y, SceneGridType.Obstacle)
end