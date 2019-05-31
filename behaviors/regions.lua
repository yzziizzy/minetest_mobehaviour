 
bt.register_action("FindNodeInRange", {
	tick = function(node, data)
		if data.region == nil or node.regionEmpty == true then 
			print("could not find node in active range")
			return "failed" 
		end
		
		return "success"
	end,
	
	reset = function(node, data)
		local r = data.region;
		if r == nil then -- game restarts cause this
			return
		end
		local list = minetest.find_nodes_in_area(r.min, r.max, node.sel)
		--[[
		print("searching for node in region "..node.sel[1].."\n")
		print("search range: y="..r.min.y.." @ "..
				"["..r.min.x..", "..r.min.y..", "..r.min.z.."], "..
				"["..r.max.x..", "..r.max.y..", "..r.max.z.."]\n")
		print("found "..#list.." nodes\n")
		]]
		if list ~= nil and #list > 0 then
			node.regionEmpty = false
			local n = list[1]
			local node = minetest.get_node(n)
			-- debug -- print("name: " .. node.name .. "\n")
			-- debug -- print("targeting node ["..n.x..", "..n.y..", "..n.z.."]\n")
			data.targetPos = n
		else 
			node.regionEmpty = true
		end
	end,
	
	ctor = function(sel)
		return {
			sel = sel,
			regionEmpty = false,
		}
	end,
})
 
bt.register_action("WalkAllNodesInRange", {
	tick = function(node, data)
		
		if data.region == nil or node.regionEmpty == true then 
			print("could not find node in active range")
			return "failed" 
		end

		if not node.initialized then 
			node.cur_pos = vcopy(data.region.min)
			data.targetPos = vcopy(node.cur_pos)
			node.done = false
			node.initialized = true
			
			return "success"
		end
		
		if node.done then 
			node.initialized = false
			return "failed"
		end
		
		data.targetPos = vcopy(node.cur_pos)
		
		node.cur_pos.x = node.cur_pos.x + 1
		if node.cur_pos.x > data.region.max.x then
			node.cur_pos.x = data.region.min.x
			node.cur_pos.z = node.cur_pos.z + 1

			if node.cur_pos.z > data.region.max.z then
				node.cur_pos.z = data.region.min.z
				node.cur_pos.y = node.cur_pos.y + 1
			
				if node.cur_pos.y > data.region.max.y then
					node.done = true
				end
			end
-- 		else
-- 			print("normal walk " .. node.cur_pos.x .. ","..node.cur_pos.y..","..node.cur_pos.z)
		end
		
		return "success"
	end,
		
	ctor = function(sel)
		return {
			sel = sel,
			regionEmpty = false,
			cur_pos = {x=0, y=0, z=0},
			done = false,
			initialized = false,
		}
	end,
})


bt.register_action("WalkNonEmptyNodesInRange", {
	tick = function(node, data)
		
		if data.region == nil or node.regionEmpty == true then 
			print("could not find node in active range")
			return "failed" 
		end

		if not node.initialized then 
			node.cur_pos = vcopy(data.region.min)
			node.done = false
			node.initialized = true
		end
		
		if node.done then 
			node.initialized = false
			return "failed"
		end
		
		
		local found = false
		while not node.done and not found do
			
			local n = minetest.get_node(node.cur_pos)
			if n and n.name ~= "air" and n.name ~= "ignore" then
				found = true
				break
			end
		
			node.cur_pos.x = node.cur_pos.x + 1
			if node.cur_pos.x > data.region.max.x then
				node.cur_pos.x = data.region.min.x
				node.cur_pos.z = node.cur_pos.z + 1

				if node.cur_pos.z > data.region.max.z then
					node.cur_pos.z = data.region.min.z
					node.cur_pos.y = node.cur_pos.y + 1

					if node.cur_pos.y > data.region.max.y then
						node.done = true
					end
				end
-- 			else
-- 				print("normal walk " .. node.cur_pos.x .. ","..node.cur_pos.y..","..node.cur_pos.z)
			end
			
		
		
		end
		
		if not found then
			return "failed"
		end
		
		data.targetPos = vcopy(node.cur_pos)
		
		return "success"
	end,
	
	reset = function(node, data)
		local r = data.region;
		if r == nil then -- game restarts cause this
			return
		end
		
	end,
	
	ctor = function(sel)
		return {
			sel = sel,
			regionEmpty = false,
			cur_pos = {x=0, y=0, z=0},
			done = false,
			initialized = false,
		}
	end,
})


bt.register_action("FindPerimeterNodeInRegion", {
	tick = function(node, data)
		if data.region == nil or node.regionEmpty == true then 
			-- debug -- print("could not find edge node in active region")
			return "failed" 
		end
		
		return "success"
	end,
	
	reset = function(node, data)
		local r = data.region;
		if r == nil then -- game restarts cause this
			return
		end
		
		node.regionEmpty = false
		
		local list
		
		-- first try the x+ edge
		list = minetest.find_nodes_in_area({
			x= r.max.x,
			y= r.min.y,
			z= r.min.z,
		}, {
			x= r.max.x,
			y= r.max.y,
			z= r.max.z,
		}, node.sel)
		if list ~= nil and #list > 0 then
			local n = list[1]
			local node = minetest.get_node(n)
			-- debug -- print("name: " .. node.name .. "\n")
			-- debug -- print("targeting node ["..n.x..", "..n.y..", "..n.z.."]\n")
			data.targetPos = n
			
			return
		end 

		-- next try the z+ edge
		list = minetest.find_nodes_in_area({
			x= r.min.x,
			y= r.min.y,
			z= r.max.z,
		}, {
			x= r.max.x,
			y= r.max.y,
			z= r.max.z,
		}, node.sel)
		if list ~= nil and #list > 0 then
			local n = list[1]
			local node = minetest.get_node(n)
			-- debug -- print("name: " .. node.name .. "\n")
			-- debug -- print("targeting node ["..n.x..", "..n.y..", "..n.z.."]\n")
			data.targetPos = n
			
			return
		end 
		
		
		-- next try the x- edge
		list = minetest.find_nodes_in_area({
			x= r.min.x,
			y= r.min.y,
			z= r.min.z,
		}, {
			x= r.min.x,
			y= r.max.y,
			z= r.max.z,
		}, node.sel)
		if list ~= nil and #list > 0 then
			local n = list[1]
			local node = minetest.get_node(n)
			-- debug -- print("name: " .. node.name .. "\n")
			-- debug -- print("targeting node ["..n.x..", "..n.y..", "..n.z.."]\n")
			data.targetPos = n
			
			return
		end 
		
		-- lastly try the z- edge
		list = minetest.find_nodes_in_area({
			x= r.min.x,
			y= r.min.y,
			z= r.min.z,
		}, {
			x= r.max.x,
			y= r.max.y,
			z= r.min.z,
		}, node.sel)
		if list ~= nil and #list > 0 then
			local n = list[1]
			local node = minetest.get_node(n)
			-- debug -- print("name: " .. node.name .. "\n")
			-- debug -- print("targeting node ["..n.x..", "..n.y..", "..n.z.."]\n")
			data.targetPos = n
			
			return
		end 
		
		-- no nodes left
		node.regionEmpty = true
	end,
	
	ctor = function(sel)
		return {
			sel = sel,
			regionEmpty = false,
		}
	end,
})




bt.register_action("ScaleRegion", {
	tick = function(node, data)
		if data.region == nil then 
			-- debug -- print("no active region")
			return "failed" 
		end
		
		return "success"
	end,
	
	reset = function(node, data)
		local r = data.region;
		if r == nil then -- game restarts cause this
			return
		end
		
		data.region = {
			min={x = r.min.x - node.scale.x, y = r.min.y - node.scale.y, z = r.min.z - node.scale.z}, 
			max={x = r.max.x + node.scale.x, y = r.max.y + node.scale.y, z = r.max.z + node.scale.z}, 
		}
		
		r = data.region
		--[[
		print("region scaled to: y="..r.min.y.." @ "..
			"["..r.min.x..", "..r.min.y..", "..r.min.z.."], "..
			"["..r.max.x..", "..r.max.y..", "..r.max.z.."]\n")
		]]
	end,
	
	ctor = function(scale)
		return {
			scale = scale,
		}
	end,
})


bt.register_action("MoveRegion", {
	tick = function(node, data)
		if data.region == nil then 
			-- debug -- print("no active region")
			return "failed" 
		end
		
		return "success"
	end,
	
	reset = function(node, data)
		local r = data.region;
		if r == nil then -- game restarts cause this
			return
		end
		
		data.region = {
			min={x = r.min.x + node.scale.x, y = r.min.y + node.scale.y, z = r.min.z + node.scale.z}, 
			max={x = r.max.x + node.scale.x, y = r.max.y + node.scale.y, z = r.max.z + node.scale.z}, 
		}
		
		r = data.region
		--[[
		print("region moved to: y="..r.min.y.." @ "..
			"["..r.min.x..", "..r.min.y..", "..r.min.z.."], "..
			"["..r.max.x..", "..r.max.y..", "..r.max.z.."]\n")
		]]
	end,
	
	ctor = function(scale)
		return {
			scale = scale,
		}
	end,
})



bt.register_action("FindRegionAround", {
	tick = function(node, data)
		if data.targetPos == nil then 
			-- debug -- print("could not find spot on ground")
			return "failed" 
		end
		
		return "success"
	end,
	
	reset = function(node, data)
		-- really shitty quick hack
		if data.targetPos ~= nil then
			local tp = data.targetPos
			tp.y = tp.y - 1
			data.region = {
				min= {x=tp.x - node.radius, y=tp.y, z=tp.z - node.radius},
				max= {x=tp.x + node.radius, y=tp.y, z=tp.z + node.radius},
			}
			
			--[[
			print("range set to y="..tp.y.." @ "..
				"["..data.region.min.x..", "..data.region.min.z.."], "..
				"["..data.region.max.x..", "..data.region.max.z.."]\n")
			]]
		end
	end,
	
	ctor = function(radius)
		return {
			radius = radius,
		}
	end,
})
