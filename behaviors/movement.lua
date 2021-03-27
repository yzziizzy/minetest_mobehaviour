 

bt.register_action("Approach", {
	tick = function(node, data)
		if data.targetPos == nil then
			print("A: failed")
			return "failed" 
		end
		--print(dump(data.mob))
		
		--[[
		if data.mob.walk_aborted == true then
			data.mob.walk_aborted = false
		print("B: failed")
			return "failed"
		end
		
		if data.mob.arrived == true then
			data.mob.arrived = false
		print("C: success")
			return "success"
		end
		]]
		--print("D: ")
		local d = distance(data.pos, data.targetPos)
		
		print("D: dist: "..d)
		
		if d <= node.dist then
			print("arrived at target")
			print("E: success")
			return "success"
		end
		
		print("F: running")
		return "running"
	end,
	
	reset = function(node, data)
		if data.targetPos ~= nil then
			print("Approaching target ("..data.targetPos.x..","..data.targetPos.y..","..data.targetPos.z..")")
			data.mob.destination = data.targetPos
			data.mob.approachDistance = node.dist
		else 
			print("Approach: targetPos is nil")
		end
	end,
	
	ctor = function(dist)
		return {
			dist=dist,
		}
	end,
})



bt.register_action("TryApproach", {
	tick = function(node, data)
		if data.targetPos == nil then 
			return "failed" 
		end
		
		if data.mob.walk_aborted == true then
			return "failed"
		end
		
		if data.mob.arrived == true then
			return "success"
		end
		
		local d = distance(data.pos, data.targetPos)
		
		if d <= node.dist then
			-- debug -- print("arrived at target")
			node.last_d = nil
			return "success"
		end
		
		
		if node.last_d == nil then
			node.last_d = d
		else 
			local dd = math.abs(node.last_d - d)
			--print("last_d: " .. node.last_d .. " d: "..d.." dist: ".. dd)
			if dd < .02 then
				-- we're stuck
				node.last_d = nil
				return "failed"
			end
			
			node.last_d = d
		end

		return "running"
	end,
	
	reset = function(node, data)
		node.last_d = nil

		if data.targetPos ~= nil then
			-- debug -- print("Approaching target ("..data.targetPos.x..","..data.targetPos.y..","..data.targetPos.z..")")
			data.mob.destination = data.targetPos
			data.mob.approachDistance = node.dist
		else 
			-- debug -- print("Approach: targetPos is nil")
		end
	end,
	
	ctor = function(dist)
		return {
			dist=dist,
		}
	end,
})


bt.register_action("FindPath", {
	tick = function(node, data)
		if data.targetPos == nil or data.mob.path == nil then 
			return "failed" 
		end
		
		local d = distance(data.pos, data.targetPos)
		
		-- debug -- print("dist: "..d)
		
		if d <= .1 then
			-- debug -- print("arrived at target")
			return "success"
		end
		
		return "running"
	end,
	
	reset = function(node, data)
		if data.targetPos ~= nil then
			
			local path = minetest.find_path(data.pos, data.targetPos, node.searchDistance, node.maxJump, node.maxFall)
			
			data.mob.path = path
		else 
			-- debug -- print("FindPath: targetPos is nil")
		end
	end,
	
	ctor = function(searchDist, maxJump, maxFall)
		return {
			searchDist=searchDist or 10,
			maxJump=maxJump or 1,
			maxFall=maxFall or 3,
		}
	end,
})



bt.register_action("PushTarget", {
	tick = function(node, data)
		if data.targetPos == nil then
			return "failed"
		end
	
		local pos = {x= data.targetPos.x, y= data.targetPos.y, z= data.targetPos.z}
		table.insert(data.posStack, pos)
		return "success"
	end,
})

bt.register_action("PopTarget", {
	tick = function(node, data)
		if #data.posStack == 0 then
			return "failed"
		end
	
		data.targetPos = table.remove(data.posStack)
		return "success"
	end,
})


-- changes to a different registered pace
bt.register_action("SetPace", {
	tick = function(node, data)
		data.mob.pace = node.pace
		return "success"
	end,
	
	ctor = function(pace) return { pace = pace } end,
})

-- sets the speed for a pace
bt.register_action("SetSpeed", {
	tick = function(node, data)
		data.mob.pace_velocity[node.pace] = node.speed
		return "success"
	end,
	
	ctor = function(pace, speed) 
		return { 
			pace = pace,
			speed = speed,
		}
	end,
})
