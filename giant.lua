--[[
forager
farmer

crafter
guards (need weapons)

fix lumberjack stuck on trees

torches
moat
walls (need perimeter fn)
stairs, positional


find node far away from
flee function


make mobs open doors
make mobs climb ladders
approach with timeout/stuck fn

]]





local forager = function() 
	local food_items = {
		"default:apple",
		"group:sapling",
	}
	
	local food_nodes = {
		"default:apple",
		"flowers:mushroom_brown",
	}

	return bt.Sequence("", {
		bt.Succeed(bt.FindGroupCampfire()),
		
		bt.Counter("items_in_hand", "set", 0),
		bt.Invert(bt.Selector("find some food", {
			btu.forage_item(food_items, 20, "items_in_hand", 4),
			btu.forage_node(food_nodes, 20, "items_in_hand", 4),
			
			btu.forage_item(food_items, 40, "items_in_hand", 4),
			btu.forage_node(food_nodes, 40, "items_in_hand", 4),
		})),
		
		
		bt.GetGroupWaypoint("food_chest"),
		bt.Approach(2),
		bt.PutInChest(nil),
		
		bt.WaitTicks(1),
	})
end

local lumberjack = function() 
	return bt.Sequence("", {
		bt.Succeed(bt.FindGroupCampfire()),
		
		-- build a chest and remember where it is
		--bt.FindSpotOnGround(),
		--bt.SetNode({name="default:chest"}),
		bt.GetGroupWaypoint("lumber_chest"),
		bt.SetWaypoint("chest"),
		
		bt.UntilFailed(bt.Sequence("logs some trees", {
			
			-- find a tree
			bt.Selector("find a tree", {
				bt.Sequence("find a tree near the last one", {
					bt.GetWaypoint("tree"),
					bt.FindNodeNear({"group:tree"}, 15),
				}),
				bt.FindNodeNear({"group:tree"}, 50),
			}),
			bt.Approach(2),
			
			-- chop it down
			bt.Invert(bt.UntilFailed(bt.Sequence("chop tree", {
				bt.Wield("default:axe_steel"),
				bt.Animate("punch"),
				bt.FindNodeNear({"group:tree"}, 3),
				bt.DigNode(),
				bt.WaitTicks(1),
			}))),
			bt.SetWaypointHere("tree"),

			bt.Wield(""),

			
			bt.Succeed(bt.Sequence("pick up saplings", {
				--bt.FindItemNear("group:sapling", 20),
				bt.PickUpNearbyItems("group:sapling", 5),
			})),
			
			
			-- put wood in chest
			bt.GetGroupWaypoint("lumber_chest"),
			bt.Approach(2),
			bt.PutInChest(nil),
			
                                  
			bt.WaitTicks(1),
			bt.Print("end of loop \n"),
		}))
	})
end

local fence_region = function(item)
	return bt.Sequence("", {

		bt.Invert(bt.UntilFailed(bt.Sequence("fill region", {
			
			bt.FindPerimeterNodeInRegion({"air"}),
			bt.Approach(2),
			
			-- chop it down
			bt.Invert(bt.UntilFailed(bt.Sequence("fill region", {
				bt.FindPerimeterNodeInRegion({"air"}),
				bt.Approach(3),
				bt.Animate("punch"),
				bt.SetNode(item);
				bt.WaitTicks(1),
			}))),
			
			bt.Print("end of loop"),
		})))
	})
end

local wander_around = function() 
	return bt.Sequence("wander", {
		bt.Print("wandering"),
		bt.FindSpotOnGround(),
		bt.MoveTargetRandom({x=8,y=0,z=8}),
		bt.Approach(2),
		--bt.Animate("walk"),
		--bt.SetNode(item);
		--bt.WaitTicks(1),
	})
	
end

local build_house = function(item) 
	return bt.Sequence("", {
		bt.Succeed(bt.FindGroupCampfire()),
	
		-- find a place for a hole
		bt.FindSpotOnGround(),
		bt.SetWaypoint("house"),
		bt.FindRegionAround(3),
		
		bt.MoveRegion({x=0, y=1, z=0}),
		btu.fill_region({name="default:cobble"}),
		
		bt.MoveRegion({x=0, y=1, z=0}),
		btu.fence_region({name="default:tree"}),

		bt.MoveRegion({x=0, y=1, z=0}),
		btu.fence_region({name="default:tree"}),
		
		bt.ScaleRegion({x=-1, y=0, z=-1}),
		bt.MoveRegion({x=0, y=1, z=0}),
		btu.fill_region({name="default:wood"}),

		bt.ScaleRegion({x=-1, y=0, z=-1}),
		bt.MoveRegion({x=0, y=1, z=0}),
		btu.fill_region({name="default:wood"}),
		
		bt.Die(),
	})
end





local build_campfire = function() 
	return bt.Sequence("build campfire", {
		bt.FindSpotOnGround(),
		bt.SetWaypoint("campfire"),

-- 		bt.FindRegionAround(2),
-- 		dig_region({"group:soil", "group:plant", "group:sand"}),
-- 		fill_region({name="default:gravel"}),

		bt.GetWaypoint("campfire"),
		bt.MoveTarget({x=0, y=-1, z=0}),

		bt.Animate("punch"),
	
		bt.DigNode(),
		bt.SetNode({name="default:coalblock"}),
		bt.WaitTicks(1),
	
		bt.MoveTarget({x=1, y=1, z=0}),
		bt.SetNode({name="stairs:slab_cobble"}),
		bt.WaitTicks(1),
		
		bt.MoveTarget({x=-1, y=0, z=1}),
		bt.SetNode({name="stairs:slab_cobble"}),
		bt.WaitTicks(1),
		
		bt.MoveTarget({x=-1, y=0, z=-1}),
		bt.SetNode({name="stairs:slab_cobble"}),
		bt.WaitTicks(1),
		
		bt.MoveTarget({x=1, y=0, z=-1}),
		bt.SetNode({name="stairs:slab_cobble"}),
		bt.WaitTicks(1),
		
		bt.MoveTarget({x=0, y=0, z=1}),
		bt.SetNode({name=mn..":campfire"}),
		
		bt.FindGroupCampfire(),
		bt.SetRole("founder"),
	})

end


local spawn_at_campfire = function(role)
	return bt.Sequence("spawn at campfire", {
		bt.PushTarget(),
		bt.GetGroupWaypoint("spawnpoint"),
		bt.MoveTargetRandom({x=1, y=0, z=1}),
		bt.Spawn(role),
		bt.PopTarget(),
	})
end


local found_village = function() 
	return bt.Sequence("founding village", {
		build_campfire(),
		
		bt.MoveTarget({x=2, y=0, z=2}),
		bt.SetGroupWaypoint("spawnpoint"),
		
		bt.MoveTarget({x=-5, y=0, z=1}),
		bt.SetGroupWaypoint("lumber_chest"),
		bt.SetNode({name="default:chest"}),
		
		bt.MoveTarget({x=0, y=0, z=-6}),
		bt.SetGroupWaypoint("stone_chest"),
		bt.SetNode({name="default:chest"}),
		
		bt.MoveTarget({x=6, y=0, z=6}),
		bt.SetGroupWaypoint("food_chest"),
		bt.SetNode({name="default:chest"}),
		
		bt.WaitTicks(1),
		spawn_at_campfire("lumberjack"),
		
		bt.WaitTicks(2),
		spawn_at_campfire("lumberjack"),
		
		--build_house(),
				
		bt.Die(),
	})
end





local quarry = function(item) 
	return bt.Sequence("", {
		bt.Succeed(bt.FindGroupCampfire()),
	
		-- build a chest and remember where it is
		bt.FindSpotOnGround(),
		bt.SetNode({name="default:chest"}),
		bt.SetWaypoint("chest"),
		
		bt.UntilFailed(bt.Sequence("dig some dirt", {
			
			-- find a tree
			bt.Selector("find a tree", {
				bt.Sequence("find a tree near the last one", {
					bt.GetWaypoint("tree"),
					bt.FindNodeNear(item, 15),
				}),
				bt.FindNodeNear(item, 50),
			}),
			bt.Approach(2),
			
			-- chop it down
			bt.Counter("foo", "set", 0),
			bt.Invert(bt.UntilFailed(bt.Sequence("chop tree", {
				bt.Animate("punch"),
				bt.FindNodeNear(item, 2),
				bt.DigNode(),
				bt.WaitTicks(1),
				bt.Counter("foo", "inc"),
				bt.Invert(bt.Counter("foo", "eq", 3)),
			}))),
			bt.SetWaypointHere("tree"),
			
			
			-- put wood in chest
			bt.GetWaypoint("chest"),
			bt.Approach(2),
			bt.PutInChest(nil),
			
			bt.WaitTicks(1),
			
			bt.Print("end of loop"),
		}))
	})
end


local burn_shit = function(what) 
	return bt.Sequence("", {
		-- build a chest and remember where it is
		bt.FindNewNodeNear(what, 50),
		bt.Approach(10),
		bt.SetWaypointHere("safe"),
		
		bt.Approach(2),
		bt.SetFire(),
		
		bt.GetWaypoint("safe"),
		bt.Approach(.1)
		
	})
end

local blow_shit_up = function(what) 
	return bt.Sequence("", {
		-- build a chest and remember where it is
		bt.FindNewNodeNear(what, 50),
		bt.Approach(10),
		bt.SetWaypointHere("safe"),
		
		bt.Approach(2),
		bt.FindNodeNear("air", 1),
		bt.SetNode({name="tnt:tnt"}),
		bt.Punch("default:torch"), -- broken
		
		bt.GetWaypoint("safe"),
		bt.Approach(.1),
		bt.WaitTicks(3),
		
	})
end


local build_walls = function(what) 
	return bt.Sequence("", {
		-- build a chest and remember where it is
		
		bt.FindNewNodeNear(what, 50),
		
		bt.Approach(10),
		bt.SetWaypointHere("center"),
		
		bt.Approach(2),
		bt.SetFire(),
		
		bt.GetWaypoint("safe"),
		bt.Approach(.1)
		
	})
end


local make_bunny = function(name, behavior_fn) 

	mobs:register_simple_mob(mn..":"..name, {
		type = "animal",
		passive = true,
		reach = 1,
		hp_min = 1,
		hp_max = 4,
		armor = 200,
		collisionbox = {-0.268, -0.5, -0.268,  0.268, 0.167, 0.268},
		visual = "mesh",
		mesh = "mobs_bunny.b3d",
		drawtype = "front",
		textures = {
			{"mobs_bunny_grey.png"},
			{"mobs_bunny_brown.png"},
			{"mobs_bunny_white.png"},
		},
		sounds = {},
		makes_footstep_sound = false,
		walk_velocity = 1,
		run_velocity = 2,
		runaway = true,
		jump = true,
		view_range = 15,
		floats = 0,
		drops = {
			{name = "mobs:meat_raw",
			chance = 1, min = 1, max = 1},
		},
		water_damage = 0,
		lava_damage = 4,
		light_damage = 0,
		fear_height = 4,
		animation = {
			speed_normal = 15,
			stand_start = 1,
			stand_end = 15,
			walk_start = 16,
			walk_end = 24,
			punch_start = 16,
			punch_end = 24,
		},
		on_rightclick = function(self, clicker)
			
		end,
		pre_activate = function(self, s,d)
			self.bt = bt.Repeat("root", nil, {
				behavior_fn();
			})
			
		end
	})
	
	mobs:register_egg(mn..":"..name, name.." Egg", "default_desert_sand.png", 1)
end

make_bunny("quarry", function() 
	return wander_around()
end)
--[[
make_giant("lumberjack", function() 
	return lumberjack()
end)

make_giant("digger", function() 
	return dig_hole({"default:dirt", "default:dirt_with_grass", "default:sand", "default:stone"})
end)]]




--mobs:register_spawn(mn..":giant", {"default:desert_sand"}, 20, 0, 7000, 2, 31000)

--mobs:register_egg(mn..":giant", "Giant", "default_desert_sand.png", 1)
