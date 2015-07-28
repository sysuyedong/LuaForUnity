Obstacle = Obstacle or BaseClass()

function Obstacle:__init()
	self.obj = nil
	self.x = 0
	self.y = 0

	self:Create()
end

function Obstacle:__delete( ... )
	if self.obj then
		GameObject.Destroy(self.obj)
	end
end

function Obstacle:Create()
	if self.obj == nil then
		self.obj = GameObject.CreatePrimitive(PrimitiveType.Cube)
	end
end

function Obstacle:SetPosition(x, y)
	self.x = x or 0
	self.y = y or 0
	if self.obj then
		self.obj.transform.position = Vector3(x, 0, y)
	end
end