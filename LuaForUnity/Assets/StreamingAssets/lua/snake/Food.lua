Food = Food or BaseClass()

FoodType = {
	Cube = PrimitiveType.Cube,
	Sphere = PrimitiveType.Sphere,
	Capsule = PrimitiveType.Capsule,
	Cylinder = PrimitiveType.Cylinder,
}

function Food:__init(type, id)
	self.type = type or FoodType.Cube
	self.id = id or 0
	self.obj = nil
	self.x = 0
	self.y = 0

	self:Create()
end

function Food:__delete( ... )
	if self.obj then
		GameObject.Destroy(self.obj)
	end
end

function Food:Create()
	if self.type then
		self.obj = GameObject.CreatePrimitive(self.type)
		self.x, self.y = SnakeModel.Instance.scene:GetRandomEmptyPositionIndex()
		self.obj.transform.position = Vector3(self.x, 0, self.y)
	end
end