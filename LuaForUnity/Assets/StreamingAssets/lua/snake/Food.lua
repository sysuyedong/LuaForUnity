Food = Food or BaseClass()

FoodType = {
	Cube = PrimitiveType.Cube,
	Sphere = PrimitiveType.Sphere,
	Capsule = PrimitiveType.Capsule,
	Cylinder = PrimitiveType.Cylinder,
}

function Food:__init(type, id)
	self.type = type or FoodType.Sphere
	self.id = id or 0
	self.obj = nil
	self.x = 0
	self.y = 0

	self:Create()
end

function Food:__delete( ... )
	if self.obj then
		self:DestroyObj(self.obj)
	end
end

function Food:DestroyObj(obj)
	local pos = obj.transform.position
	SnakeModel.Instance.scene:SetMap(pos.x, pos.z, SceneGridType.Empty)
	GameObject.Destroy(obj)
end

function Food:Create()
	if self.type then
		self.obj = GameObject.CreatePrimitive(self.type)
	end
end

function Food:SetPosition(x, y)
	self.x = x
	self.y = y
	self.obj.transform.position = Vector3(x, 0, y)
	SnakeModel.Instance.scene:SetMap(x, y, SceneGridType.Food)
end