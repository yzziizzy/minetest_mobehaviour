 


bt.register_action("SetWaypointHere", {
	tick = function(node, data)
		local pos = {x= data.pos.x, y= data.pos.y, z= data.pos.z}
		data.waypoints[node.wpname] = pos
		return "success"
	end,
	
	ctor = function(name)
		return {
			wpname=name or "_"
		}
	end,
})

bt.register_action("SetWaypoint", {
	tick = function(node, data)
		if data.targetPos == nil then 
			return "failed" 
		end
		
		local pos = {x= data.targetPos.x, y= data.targetPos.y, z= data.targetPos.z}
		data.waypoints[node.wpname] = pos
		return "success"
	end,
	
	ctor = function(name)
		return {
			wpname=name or "_"
		}
	end,
})



bt.register_action("GetWaypoint", {
	tick = function(node, data)
		if data.waypoints[node.wpname] == nil then
			return "failed"
		end
		
		local wp = data.waypoints[node.wpname]
	
		data.targetPos = {
			x = wp.x,
			y = wp.y,
			z = wp.z,
		}
		return "success"
	end,
	
	ctor = function(name)
		return {
			wpname=name or "_"
		}
	end,
})


bt.register_action("SetGroupWaypoint", {
	tick = function(node, data)
		if data.targetPos == nil or data.groupID == nil or mobehavior.groupData[data.groupID] == nil then 
			return "failed" 
		end
		
		local pos = {x= data.targetPos.x, y= data.targetPos.y, z= data.targetPos.z}
		mobehavior.groupData[data.groupID].waypoints[node.wpname] = pos
		return "success"
	end,
	
	ctor = function(name)
		return {
			wpname=name or "_"
		}
	end,
})

bt.register_action("GetGroupWaypoint", {
	tick = function(node, data)
		if data.groupID == nil 
			or mobehavior.groupData[data.groupID] == nil 
			or mobehavior.groupData[data.groupID].waypoints == nil
			or mobehavior.groupData[data.groupID].waypoints[node.wpname] == nil then
			
			-- debug -- print(dump(mobehavior.groupData[data.groupID]))
			-- debug -- print("!   failed to find group ("..data.groupID..") waypoint " .. node.wpname .. "\n")
			return "failed"
		end
	
		local wp = mobehavior.groupData[data.groupID].waypoints[node.wpname]
		
		data.targetPos = {
			x = wp.x,
			y = wp.y,
			z = wp.z,
		}
		return "success"
	end,
	
	ctor = function(name)
		return {
			wpname=name or "_"
		}
	end,
})






bt.register_action("CreatePathHere", {
	tick = function(node, data)
		if data.pos == nil then 
			return "failed" 
		end
		
		local pos = {x= data.pos.x, y= data.pos.y, z= data.pos.z}
		data.paths[node.pname] = {pos}
		return "success"
	end,
	
	ctor = function(name) return { pname=name or "_" } end,
})

bt.register_action("CreatePath", {
	tick = function(node, data)
		if data.targetPos == nil then 
			return "failed" 
		end
		
		local pos = {x= data.targetPos.x, y= data.targetPos.y, z= data.targetPos.z}
		data.paths[node.pname] = {pos}
		return "success"
	end,
	
	ctor = function(name) return { pname=name or "_" } end,
})

bt.register_action("AddPathNodeHere", {
	tick = function(node, data)
		if data.pos == nil then 
			return "failed" 
		end
		
		local pos = {x= data.pos.x, y= data.pos.y, z= data.pos.z}
		table.insert(data.paths[node.pname], pos)
		return "success"
	end,
	
	ctor = function(name) return { pname=name or "_" } end,
})

bt.register_action("AddPathNode", {
	tick = function(node, data)
		if data.targetPos == nil then 
			return "failed" 
		end
		
		local pos = {x= data.targetPos.x, y= data.targetPos.y, z= data.targetPos.z}
		table.insert(data.paths[node.pname], pos)
		return "success"
	end,
	
	ctor = function(name) return { pname=name or "_" } end,
})

bt.register_action("PointsAlongPath", {
	tick = function(node, data)
		if data.paths[node.pname] == nil then 
			return "failed" 
		end
		
		local path = data.paths[node.pname]
		
		if not node.initialized then 
			node.cur_pos = vector.round(path[1])
			node.next_seg = 2
			node.done = false
			node.initialized = true
			node.cur_dist = 0
			node.dist = distance3(path[1], path[2])
		end
		
		if node.done then 
			node.initialized = false
			return "failed"
		end
		
		
		data.targetPos = vcopy(node.cur_pos)
		
		local dir = vector.normalize(
			vector.subtract(
				path[node.next_seg], 
				path[node.next_seg - 1]
			)
		)
		
		while true do
			local next_pos = vector.round(
				vector.add(
					path[node.next_seg - 1],
					vector.multiply(dir, node.cur_dist)
				)
			)
			
			node.cur_dist = node.cur_dist + 1
			
			if node.cur_dist - 0.1 > node.dist then
				if #path <= node.next_seg then
					node.done = true
				else
					node.next_seg = node.next_seg + 1
					node.cur_dist = 0
					node.dist = distance3(path[node.next_seg-1], path[node.next_seg])
				end
			end
			
			if not vector.equals(node.cur_pos, next_pos) then
				node.cur_pos = next_pos
				break
			end
		end
		
		return "success"
	end,
	
	ctor = function(name) 
		return { 
			pname=name or "_",
			cur_pos = {x=0, y=0, z=0},
			next_seg = 2,
			done = false,
			initialized = false,
		} 
	end,
})



bt.register_action("PointsAlongPath2", {
	tick = function(node, data)
		if data.paths[node.pname] == nil then 
			return "failed" 
		end
		
		local path = data.paths[node.pname]
		
		if not node.initialized then 
			node.cur_pos = vector.round(path[1])
			node.next_seg = 2
			node.done = false
			node.initialized = true
			node.cur_dist = 0
			node.dist = distance3(path[1], path[2])
		end
		
		if node.done then 
			node.initialized = false
			return "failed"
		end
		
		
		data.targetPos = vcopy(node.cur_pos)
		
		local dir = vector.normalize(
			vector.subtract(
				path[node.next_seg], 
				path[node.next_seg - 1]
			)
		)
		
		while true do
			local next_pos = vector.round(
				vector.add(
					path[node.next_seg - 1],
					vector.multiply(dir, node.cur_dist)
				)
			)
			
			node.cur_dist = node.cur_dist + 1
			
			if node.cur_dist > node.dist then
				if #path <= node.next_seg then
					node.done = true
				else
					node.next_seg = node.next_seg + 1
					node.cur_dist = 0
					node.dist = distance3(path[node.next_seg-1], path[node.next_seg])
				end
			end
			
			if not (node.cur_pos.x == next_pos.x and node.cur_pos.z == next_pos.z) then
				node.cur_pos = next_pos
				break
			end
		end
		
		return "success"
	end,
	
	ctor = function(name) 
		return { 
			pname=name or "_",
			cur_pos = {x=0, y=0, z=0},
			next_seg = 2,
			done = false,
			initialized = false,
		} 
	end,
})



