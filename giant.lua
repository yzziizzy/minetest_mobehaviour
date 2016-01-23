



mobs:register_simple_mob("giants:giant", {
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	reach = 2,
	damage = 1,
	hp_min = 4,
	hp_max = 20,
	armor = 100,
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual = "mesh",
	mesh = "character.b3d",
	drawtype = "front",
	textures = {
		{"mobs_npc.png"},
	},
	makes_footstep_sound = true,
	walk_velocity = 1.5,
	run_velocity = 4,
	view_range = 15,
	jump = true,
	floats = 0,
	drops = {
		{name = "default:iron_lump",
		chance = 1, min = 3, max = 5},
	},
	water_damage = 0,
	lava_damage = 4,
	light_damage = 0,
	fear_height = 3,
	animation = {
		speed_normal = 30,
		speed_run = 30,
		stand_start = 0,
		stand_end = 79,
		walk_start = 168,
		walk_end = 187,
		run_start = 168,
		run_end = 187,
		punch_start = 200,
		punch_end = 219,
	},
	
	pre_activate = function(self, s,d)
		self.bt = bt.Repeat("root", nil, {bt.Sequence("", {
			-- build a chest and remember where it is
			bt.FindSpotOnGround(),
			bt.SetNode({name="default:chest"}),
			bt.SetWaypoint("chest"),
			
			bt.UntilFailed(bt.Sequence("logs some trees", {
				
				-- find a tree
				bt.FindNodeNear({"group:tree"}, 10),
				bt.Approach(1.8),
				
				-- chop it down
				bt.Invert(bt.UntilFailed(bt.Sequence("chop tree", {
					bt.FindNodeNear({"group:tree"}, 3),
					bt.DigNode(),
					bt.WaitTicks(1),
				}))),
				
				bt.Print("done chopping"),
				-- go back to chest
				bt.GetWaypoint("chest"),
				bt.Print("got waypoint"),
				bt.Approach(1.8),
				bt.Print("done approaching"),
				bt.PutInChest('default:tree'),
				bt.Print("end of loop"),
				
			}))
		})})
		
	end
})


--[[
		self.bt = bt.Repeat("root", nil, {
			bt.Sequence("snuff torches", {
				bt.FindNewNodeNear({"default:torch"}, 20, 4),
				bt.Selector("seek", {
					bt.TryApproach(1.8),
					bt.BashWalls(),
				}),
-- 				bt.Destroy(),
-- 				bt.SetFire(),
			})
		})


]]
mobs:register_spawn("giants:giant", {"default:desert_sand"}, 20, 0, 7000, 2, 31000)

mobs:register_egg("giants:giant", "Giant", "default_desert_sand.png", 1)