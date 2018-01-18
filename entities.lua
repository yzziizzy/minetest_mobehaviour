
function make_bunny(name, behavior_fn) 

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





function make_wolf(name, behavior_fn) 

	mobs:register_simple_mob(mn..":"..name, {
		
		type = "animal",
		passive = false,
		reach = 1,
		hp_min = 12,
		hp_max = 18,
		armor = 600,
		collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		visual = "mesh",
		mesh = "animal_wolf.b3d",
		drawtype = "front",
		rotate = 270,
		textures = {
			{"animal_wolf_mesh.png"},
			{"animal_wolf_tamed_mesh.png"},
		},
		sounds = {},
		makes_footstep_sound = false,
		walk_velocity = 2,
		run_velocity = 4,
		runaway = false,
		jump = true,
		view_range = 25,
		floats = 1,
		drops = {
			{name = "mobs:meat_raw",
			chance = 1, min = 1, max = 1},
		},
		water_damage = 0,
		lava_damage = 4,
		light_damage = 0,
		fear_height = 6,
		animation = {
			speed_normal = 60,
			stand_start = 0,
			stand_end = 60,
			walk_start = 61,
			walk_end = 120,
			sleep_start = 121,
			sleep_end = 180,
		},

		on_rightclick = function(self, clicker)
			
		end,
		pre_activate = function(self, s,d)
			self.bt = bt.Repeat("root", nil, {
				behavior_fn();
			})
			
		end
	})
	
	mobs:register_egg(mn..":"..name, name.." Egg", "default_silver_sand.png", 1)
end




function make_bear(name, behavior_fn) 

	mobs:register_simple_mob(mn..":"..name, {
		
		type = "animal",
		passive = false,
		reach = 1,
		hp_min = 100,
		hp_max = 180,
		armor = 600,
		collisionbox = {-0.7, -1, -0.7, 0.7, 0.7, 0.7},
		visual = "mesh",
		mesh = "mob_bear.b3d",
		drawtype = "front",
		visual_size= {x=3,y=3,z=3},
		rotate = 270,
		textures = {
			{"mob_bear_bear_mesh.png"},
		--	{"mob_bear_bear_tamed_mesh.png"}, -- has a harness
		},
		sounds = {},
		makes_footstep_sound = false,
		walk_velocity = 2,
		run_velocity = 8,
		runaway = false,
		jump = true,
		view_range = 25,
		floats = 1,
		drops = {
			{name = "mobs:meat_raw",
			chance = 1, min = 1, max = 1},
		},
		water_damage = 0,
		lava_damage = 4,
		light_damage = 0,
		fear_height = 8,
		animation = {
			speed_normal = 60,
			stand_start = 0,
			stand_end = 60,
			walk_start = 61,
			walk_end = 120,
			sleep_start = 121,
			sleep_end = 180,
		},

		on_rightclick = function(self, clicker)
			
		end,
		pre_activate = function(self, s,d)
			self.bt = bt.Repeat("root", nil, {
				behavior_fn();
			})
			
		end
	})
	
	mobs:register_egg(mn..":"..name, name.." Egg", "default_gravel.png", 1)
end




function make_rat(name, behavior_fn) 

	mobs:register_simple_mob(mn..":"..name, {
		type = "animal",
		passive = true,
		reach = 1,
		hp_min = 1,
		hp_max = 4,
		armor = 200,
		collisionbox =  {-0.2, -1, -0.2, 0.2, -0.8, 0.2},
		visual = "mesh",
		mesh = "mobs_rat.b3d",
		drawtype = "front",
		textures = {
			{"mobs_rat.png"},
			{"mobs_rat2.png"},
		},
		sounds = {
			random = "mobs_rat",
		},
		makes_footstep_sound = false,
		walk_velocity = 1,
		run_velocity = 2,
		runaway = true,
		jump = true,
		view_range = 15,
		floats = 1,
		drops = {
			{name = "mobs:meat_raw",
			chance = 1, min = 1, max = 1},
		},
		water_damage = 0,
		lava_damage = 4,
		light_damage = 0,
		fear_height = 3,
		on_rightclick = function(self, clicker)
			
		end,
		pre_activate = function(self, s,d)
			self.bt = bt.Repeat("root", nil, {
				behavior_fn();
			})
			
		end
	})
	
	mobs:register_egg(mn..":"..name, name.." Egg", "default_dirt.png", 1)
end



