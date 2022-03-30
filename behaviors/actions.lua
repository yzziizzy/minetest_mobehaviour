 


bt.register_action("Destroy", {
	tick = function(node, data)
		-- debug -- print("Destroying target")
		if data.targetPos == nil then 
			return "failed" 
		end
		
		-- too far away
		if distance(data.targetPos, data.pos) > data.mob.reach then
			return "failed"
		end
		
		minetest.set_node(data.targetPos, {name="air"})
		
		return "success"
	end,
})

bt.register_action("PunchEntity", {
	tick = function(node, data)
		-- debug -- print("Punching target entity")
		if data.targetEntity == nil then 
			return "failed" 
		end
		
		-- too far away
		if distance3(data.targetEntity:getpos(), data.pos) > data.mob.reach then
			return "failed"
		end
		
		--print(dump(data.targetEntity))
		data.targetEntity:punch(data.mob.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = data.mob.damage}
		}, nil)
		
		return "success"
	end,
})




bt.register_action("BashWalls", {
	tick = function(node, data)
		local pos = minetest.find_node_near(data.pos, 2, {"default:wood"})
		if pos == nil then
			return "failed"
		end
			
		minetest.set_node(pos, {name="air"})
		
		return "success"
	end,
})





bt.register_action("SetFire", {
	tick = function(node, data)
		-- debug -- print("setting fire to target")
		if data.targetPos == nil then 
			return "failed" 
		end
		
		-- too far away
		if distance(data.targetPos, data.pos) > data.mob.reach then
			return "failed"
		end
		
		local pos = fire.find_pos_for_flame_around(data.targetPos)
		if pos ~= nil then
			minetest.set_node(pos, {name = "fire:basic_flame"})
		end
		
		return "success"
	end,
})


bt.register_action("SetNode", {
	tick = function(node, data)
		if data.targetPos == nil then 
			return "failed" 
		end
		
		minetest.set_node(data.targetPos, node.sel)
		
		return "success"
	end,
	
	ctor = function(sel)
		if type(sel) == "string" then
			sel = {name = sel}
		end
		return { 
			sel = sel 
		} 
	end,
})


bt.register_action("SetNodeRel", {
	tick = function(node, data)
		if data.targetPos == nil then 
			return "failed" 
		end
		
		minetest.set_node(vector.add(data.targetPos, node.off), node.sel)
		
		return "success"
	end,
	
	ctor = function(sel, offset, dir)
		if type(sel) == "string" then
			sel = {name = sel}
		end
		
		if dir then
			sel.param2 = minetest.dir_to_facedir(dir)
		end
		
		return { 
			sel = sel,
			off = offset,
			facedir = facedir,
		} 
	end,
})


bt.register_action("SetNodeRelWallmounted", {
	tick = function(node, data)
		if data.targetPos == nil then 
			return "failed" 
		end
		
		minetest.set_node(vector.add(data.targetPos, node.off), node.sel)
		
		return "success"
	end,
	
	ctor = function(sel, offset, dir)
		if type(sel) == "string" then
			sel = {name = sel}
		end
		
		if dir then
			sel.param2 = minetest.dir_to_wallmounted(dir)
		end
		
		return { 
			sel = sel,
			off = offset,
			facedir = facedir,
		} 
	end,
})



bt.register_action("SetNodeWallmounted", {
	tick = function(node, data)
		if data.targetPos == nil then 
			return "failed" 
		end
		
		minetest.set_node(data.targetPos, node.sel)
		
		return "success"
	end,
	
	ctor = function(sel, dir)
		if type(sel) == "string" then
			sel = {name = sel}
		end
		
		sel.param2 = minetest.dir_to_wallmounted(dir)
		
		return { 
			sel = sel,
		} 
	end,
})



bt.register_action("ExtinguishFire", {
	tick = function(node, data)
		-- debug -- print("Extinguishing nearby fire")
		
		local pos = minetest.find_node_near(data.pos, data.mob.reach, {"fire:basic_flame"})
		if pos == nil then 
			return "success" 
		end
		
		minetest.set_node(pos, {name = "air"})
		
		return "running"
	end,
})


bt.register_action("DigNode", {
	tick = function(node, data)
		
		if data.targetPos == nil then 
			-- debug -- print("!   [DigNode] no target position\n")
			return "failed" 
		end
		
		local n = minetest.get_node_or_nil(data.targetPos)
		if n == nil then
			-- debug -- print("!   [DigNode] node is nil\n")
			return "success"
		end
		
		local drops = minetest.get_node_drops(n.name)
		for _,i in ipairs(drops) do
			data.inv:add_item("main", i)
		end
		
		minetest.remove_node(data.targetPos)
		
		return "success"
	end,
})

bt.register_action("PutInChest", {
	tick = function(node, data)
		if data.targetPos == nil then
			-- debug -- print("!   [PutInChest] no target position\n") 
			return "failed"
		end

		local inv = minetest.get_inventory({type="node", pos=data.targetPos}) 
		if inv == nil then 
			-- debug -- print("!   [PutInChest] failed to get inv for "..dump(data.targetPos).."\n") 
			return "failed"
		end
		
		local list = data.inv:get_list("main")
		if list == nil then
			-- debug -- print("@   [PutInChest] main list is nil\n") 
			return "success"
		end
		local to_move = {}
		for k,i in ipairs(list) do
			if node.sel == nil or i:get_name() == node.sel then
				-- debug -- print("adding item")
				inv:add_item("main", i)
				list[k] = nil
				--table.insert(to_move, i)
			end
		end
		

		data.inv:set_list("main", list)
		--local leftovers = inv:add_item("main", items) 
		
		
		return "success"
	end,
	
	ctor = function(sel) return { sel = sel } end,
})

bt.register_action("RobChestRandom", {
	tick = function(node, data)
		if data.targetPos == nil then
			-- debug -- print("!   [RobChestRandom] no target position\n") 
			return "failed"
		end

		local inv = minetest.get_inventory({type="node", pos=data.targetPos}) 
		if inv == nil then 
			-- debug -- print("!   [RobChestRandom] failed to get inv for "..dump(data.targetPos).."\n") 
			return "failed"
		end
		
		local mainsz = inv:get_size("main")
		if mainsz == nil then
			-- debug -- print("@   [RobChestRandom] main list is nil\n") 
			return "success"
		end
		
		local to_take = node.count
		for i = 1, mainsz do
			local st = inv:get_stack("main", i)
		--	print("item: " .. i .." - ".. st:get_name())
			if st:get_name() ~= "" then
			--	print("taking item " .. st:get_name())
				
				local n = st:get_count()
				local rem = n - to_take;
				if rem < 0 then
					to_take = -rem
					rem = 0
				else 
					to_take = 0
				end
				
				st:set_count(rem)
				inv:set_stack("main", i, st)
				
				if to_take <= 0 then break end
			end
		end
		
		if to_take > 0 then
			minetest.set_node(data.targetPos, {name="default:chest_open"})
		end
		
		
		--local leftovers = inv:add_item("main", items) 
		
		
		return "success"
	end,
	
	ctor = function(count) return { count = count } end,
})


bt.register_action("Die", {
	tick = function(node, data)
		-- debug -- print("Dying now")
		
		-- TODO: remove inv and global data
		
		data.mob.object:remove()
		
		return "success"
	end,
})


bt.register_action("Spawn", {
	tick = function(node, data)
		local pos = {x = data.targetPos.x, y = data.targetPos.y + 2, z = data.targetPos.z}
		
		local name = "mobehavior:giant_"..node.role 
		local mob = minetest.add_entity(pos, name)
		
		return "success"
	end,
	
	ctor = function(role) return { role = role } end,
})


bt.register_action("PickUpNearbyItems", {
	tick = function(node, data)
		
		local objects = minetest.get_objects_inside_radius(data.pos, node.dist)
		for _,object in ipairs(objects) do
			if not object:is_player() and object:get_luaentity() and object:get_luaentity().name == "__builtin:item" then
				if object:get_luaentity().itemstring == node.sel then
					if data.inv:room_for_item("main", ItemStack(object:get_luaentity().itemstring)) then
						data.inv:add_item("main", ItemStack(object:get_luaentity().itemstring))
						object:get_luaentity().itemstring = ""
						object:remove()
					end
				end
			end
		end
		
		
		return "success"
	end,
	
	ctor = function(sel, dist)
		return {
			sel = sel,
			dist = dist,
		}
	end,
})


bt.register_action("Punch", {
	tick = function(node, data)
		-- debug -- print("Punching with " .. node.tool)
		
		if data.targetPos == nil then 
			return "failed" 
		end
		
		local ret = data.mob.object:set_wielded_item(node.tool)
		if ret == false then
			-- debug -- print("failed to set tool")
			return "failed"
		end
		local n = minetest.get_node(data.targetPos)
		minetest.node_punch(data.targetPos, n, data.mob.object) -- broken
		--minetest.punch_node(data.targetPos)
		
		return "running"
	end,
	
	ctor = function(tool)
		return {
			tool=tool
		}
	end,
})

bt.register_action("AddHealth", {
	tick = function(node, data)
		local hp = data.mob.object:get_hp()
		data.mob.object:set_hp(hp + node.n)
		return "success"
	end,
	
	ctor = function(n) 
		return {
			n = n
		}
	end,
})



bt.register_action("FireProjectileAt", {
	tick = function(node, data)
		-- debug -- print("Punching with " .. node.tool)
		
		if data.targetPos == nil then 
			return "failed" 
		end
		
		mobehavior:fire_projectile_at(node.projName, data.mob.last_pos, data.targetPos)
		
		return "success"
	end,
	
	ctor = function(projName)
		return {
			projName=projName,
		}
	end,
})
