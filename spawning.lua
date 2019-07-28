




-- rats
minetest.register_abm({
	nodenames = {
		"default:dirt", 
		"default:dirt_with_grass", 
		"default:dirt_with_dry_grass", 
		"seasons:spring_default_dirt_with_grass",
		"seasons:fall_default_dirt_with_grass",
		"seasons:winter_default_dirt_with_grass",
		"default:dirt_with_rainforest_litter",
		"default:dirt_with_coniferous_litter",
		"default:desert_sand",
		"default:silver_sand",
		"default:gravel",
		
	},
	neighbors = {"air"},
	interval = 30,
	chance = 1000,
	catch_up = false,

	action = function(pos, node, active_object_count, active_object_count_wider)
-- 		print("spawn rat")
		if active_object_count > 3 then
			--print("too many local objs " .. active_object_count)
			return
		end
		
		local nearobjs = minetest.get_objects_inside_radius(pos, 30)
		if #nearobjs > 4 then
			--print("too many near objs")
			return
		end
		
		--print("----------spawning rat")
		local p = minetest.find_node_near(pos, 3, "air")
		if p then
			local mob = minetest.add_entity(p, "mobehavior:rat")
		end
	end
})





-- wolves
minetest.register_abm({
	nodenames = {
		"default:dirt_with_coniferous_litter",
	},
	neighbors = {"air"},
	interval = 60,
	chance = 400,
	catch_up = false,

	action = function(pos, node, active_object_count, active_object_count_wider)
		if active_object_count_wider > 0 then
			--print("too many local objs")
			return
		end
		
		local nearobjs = minetest.get_objects_inside_radius(pos, 40)
		if #nearobjs > 0 then
-- 			print("------")
			for _,o in ipairs(nearobjs) do
				local p = o:get_luaentity()
				if p and p.name == "wolf" then
					count = count + 1
					if count > 1 then
						return
					end
				end
			end
			
			--print("too many near objs")
			return
		end
		--print("----------spawning rat")
		local p = minetest.find_node_near(pos, 3, "air")
		if p then
			local mob = minetest.add_entity(p, "mobehavior:wolf")
		end
	end
})




-- bunnies
minetest.register_abm({
	nodenames = {
		"default:dirt_with_grass", 
		"seasons:spring_default_dirt_with_grass",
		"default:dirt_with_coniferous_litter",
		"default:desert_sand",
		"default:silver_sand",
	},
	neighbors = {"air"},
	interval = 4,
	chance = 80,
	catch_up = false,

	action = function(pos, node, active_object_count, active_object_count_wider)
		if active_object_count > 2 then
			--print("too many local objs " .. active_object_count)
			return
		end
		
		local nearobjs = minetest.get_objects_inside_radius(pos, 40)
		if #nearobjs > 4 then
			--print("too many near objs")
			return
		end
		
		--print("----------spawning rat")
		local p = minetest.find_node_near(pos, 3, "air")
		if p then
			local mob = minetest.add_entity(p, "mobehavior:bunny")
		end
	end
})



-- brown bears
minetest.register_abm({
	nodenames = {
		"default:dirt_with_grass", 
		"seasons:spring_default_dirt_with_grass",
		"default:dirt_with_coniferous_litter",
	},
	neighbors = {"air"},
	interval = 6,
	chance = 150,
	catch_up = false,

	action = function(pos, node, active_object_count, active_object_count_wider)
		if active_object_count > 5 then
			--print("too many local objs " .. active_object_count)
			return
		end
		
		local nearobjs = minetest.get_objects_inside_radius(pos, 40)
		if #nearobjs > 0 then
-- 			print("------")
			for _,o in ipairs(nearobjs) do
				local p = o:get_luaentity()
				if p and p.name == "bear" then
					count = count + 1
					if count > 1 then
						return
					end
				end
			end
			
			--print("too many near objs")
			return
		end
		
		--print("----------spawning rat")
		local p = minetest.find_node_near(pos, 3, "air")
		if p then
			local mob = minetest.add_entity(p, "mobehavior:bear")
		end
	end
})


