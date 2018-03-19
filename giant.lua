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

local wander_around = function(dist) 
	return bt.Sequence("wander", {
		bt.Print("wandering"),
		bt.RandomDirection(),
		bt.MoveInDirection(dist),
		--bt.Animate("walk"),
		--bt.SetNode(item);
		bt.WaitTicks(1),
	})
	
end

local seek_food = function(dist, food_nodes) 

	return bt.Sequence("seek_food", {
		bt.FindNodeNear(food_nodes, dist),
		bt.Approach(1.2),
		bt.Animate("punch"),
		bt.WaitTicks(3),
		bt.DigNode(),
		bt.AddHealth(1),
		bt.Animate("stand"),
	})
end

local bunny_root = function() 
	local food = {
		"group:wheat",
		"group:cotton",
		"group:rice",
		"group:grass",
		"group:flower",
		"group:plant",
	}

	return bt.Sequence("bunny", {
		bt.Random({
			wander_around(2),
			wander_around(4),
			wander_around(6),
			wander_around(8),
			bt.WaitTicks(1),
			bt.WaitTicks(1),
			bt.WaitTicks(2),
			bt.WaitTicks(2),
			seek_food(6, food),
			
			-- breeding
		})
	})
end


local wolf_root = function() 
	return bt.Sequence("wolf", {
		
		-- FindEntityNear
		-- ApproachEntity
		-- Attack
		
	})


end


local raid_chest = function(dist, qty)
	return bt.Sequence("raid_chest", {
		bt.FindNodeNear({"default:chest"}, dist),
		bt.Approach(1.2),
		bt.Animate("punch"),
		bt.WaitTicks(4),
		bt.RobChestRandom(qty),
		bt.AddHealth(1),
		bt.Animate("stand"),
	})
end
local seek_and_destroy = function(dist, time, node)
	return bt.Sequence("seek_and_destroy", {
		bt.FindNodeNear(node, dist),
		bt.Approach(1.2),
		bt.Animate("punch"),
		bt.WaitTicks(time),
		bt.SetNode("air"),
		bt.Animate("stand"),
	})
end

local rat_root = function() 
	local food = {
		"group:wheat",
		"group:cotton",
		"group:rice",
	}

	return bt.Sequence("rat", {
		bt.Random({
 			wander_around(2),
			wander_around(4),
			wander_around(6),
-- 			wander_around(8),
			bt.WaitTicks(1),
-- 			bt.WaitTicks(1),
			bt.WaitTicks(2),
-- 			bt.WaitTicks(2),
			seek_food(6, food),
			raid_chest(20, 1),
			seek_and_destroy(20, 12, {"doors:door_wood_a","doors:door_wood_b", "doors:trapdoor_a", "doors:trapdoor_b"}),
			seek_and_destroy(20, 18, {"doors:door_glass_a","doors:door_glass_b"}),
			-- breeding
		})
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












make_wolf("wolf", function() 
	return wander_around(6)
end)

make_bunny("bunny", function() 
	return bunny_root()
end)
make_rat("rat", function() 
	return rat_root()
end)

make_bear("bear", function() 
	return wander_around(6)
end)

make_NPC("npc", function() 
	return wander_around(6)
end)

