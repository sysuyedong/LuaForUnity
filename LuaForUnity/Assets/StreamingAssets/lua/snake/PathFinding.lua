PathFinding = PathFinding or BaseClass()

PathFindingType = {
	Manhatton = 1,
	Euler = 2,
	Chebyshev = 3,
}

function PathFinding:__init()
	PathFinding.Instance = self

	self.map = nil
	self.width = 0
	self.height = 0
	self.type = nil
	self.path = nil
	self.start_pos = nil
	self.end_pos = nil
end

function PathFinding:getInstance()
	if PathFinding.Instance == nil then
		PathFinding.New()
	end
	return PathFinding.Instance
end

function PathFinding:__delete( ... )
end

function PathFinding:SetData(map, width, height,type)
	self.map = map
	self.width = width or 0
	self.height = height or 0
	self.type = type or PathFindingType.Manhatton
end

function PathFinding:FindPath(start_pos, end_pos)
	if self.map == nil or start_pos == nil or end_pos == nil then
		return
	end
	if start_pos.x < 0 and start_pos.x >= self.width and start_pos.z < 0 and start_pos.z >= self.height	or
		end_pos.x < 0 and end_pos.x >= self.width and end_pos.z < 0 and end_pos.z >= self.height then
		return
	end
	local visited = {}
	local list = {}
	local list_map = {}
	local function cmp(v1, v2)
		return v1.x == v2.x and v1.z == v2.z
	end
	local function count(tb)
		local n = 0
		for k, v in pairs(tb) do
			n = n + 1
		end
		return n
	end
	local function cal_and_insert(parent, p)
		-- if v is in list, update parent, g, and dis. otherwise calculate new value
		local v = list_map[p.z * self.width + p.x]
		if v then
			if parent.g + 1 < v.g then
				v.parent = parent
				v.g = parent.g + 1
				v.dis_value = self:CalculateDistance(v.p, end_pos, v.g)
			end
		else
			v = {}
			v.p = p
			v.parent = parent
			v.g = parent.g + 1
			v.dis_value = self:CalculateDistance(v.p, end_pos, v.g)
			table.insert(list, v)
			list_map[p.z * self.width + p.x] = v
		end
	end
	self.start_pos = start_pos
	self.end_pos = end_pos
	-- put the starting point to the queue
	start_v = {}
	start_v.p = start_pos
	start_v.g = 0
	start_v.dis_value = self:CalculateDistance(start_pos, end_pos, start_v.g)
	table.insert(list, start_v)
	list_map[start_pos.z * self.width + start_pos.x] = start_v
	-- repeat until find then end point
	while count(list) ~= 0 do
		-- find min distance point
		local v, index = self:GetMinDisPoint(list)
		local p = v.p
		visited[p.z * self.width + p.x] = true
		list_map[p.z * self.width + p.x] = nil
		list[index] = nil
		-- reach end point, calculate path
		if cmp(end_pos, p) then
			self.path = {}
			local item = v
			repeat
				table.insert(self.path, 1, item.p)
				item = item.parent
			until not item
			return self.path
		end
		-- search its surrounding point, calculate distance and put into list
		local up_point = Vector3(p.x, p.y, p.z + 1)
		local down_point = Vector3(p.x, p.y, p.z - 1)
		local right_point = Vector3(p.x + 1, p.y, p.z)
		local left_point = Vector3(p.x - 1, p.y, p.z)
		if self:ValidPoint(up_point) and not visited[up_point.z * self.width + up_point.x] then
			cal_and_insert(v, up_point)
		end
		if self:ValidPoint(down_point) and not visited[down_point.z * self.width + down_point.x] then
			cal_and_insert(v, down_point)
		end
		if self:ValidPoint(right_point) and not visited[right_point.z * self.width + right_point.x] then
			cal_and_insert(v, right_point)
		end
		if self:ValidPoint(left_point) and not visited[left_point.z * self.width + left_point.x] then
			cal_and_insert(v, left_point)
		end
	end
end

function PathFinding:Heuristic(v1, v2)
	local value = 999
	local abs_x = math.abs(v1.x - v2.x)
	local abs_z = math.abs(v1.z - v2.z)
	if self.type == PathFindingType.Manhatton then
		value = abs_x + abs_z
	elseif self.type == PathFindingType.Euler then
		value = math.sqrt(math.pow(abs_x, 2) + math.pow(abs_z, 2))
	elseif self.type == PathFindingType.Chebyshev then
		value = math.max(abs_x, abs_z)
	end
	return value
end

--[[
F(n) = G(n) + H(n)
F(n): the estimate distance from starting point to end point through way_pos
G(n): the actual distance from starting point to way_pos
H(n): the estimate distance from way_pos to end point
]] 
function PathFinding:CalculateDistance(way_pos, end_pos, g)
	local dis = 0
	dis = g + self:Heuristic(way_pos, end_pos)
	return dis
end

function PathFinding:GetMinDisPoint(list)
	local min = nil
	local index = nil
	for k, v in pairs(list) do
		if not min then
			min = v.dis_value
			index = k
		end
		if v.dis_value < min then
			min = v.dis_value
			index = k
		end
	end
	return list[index], index
end

function PathFinding:ValidPoint(point)
	local valid = point.x >= 0 and point.x < self.width and point.z >= 0 and point.z < self.height
	if not valid then
		return valid
	else
		local index = point.z * self.width + point.x
		return self.map[index] == SceneGridType.Empty or self.map[index] == SceneGridType.Food
	end
end