

--[[


traps
cat food dish to keep cats near





]]



minetest.register_craftitem("mobehavior:fur_small", {
	description = "Small Fur",
	inventory_image = "mobehavior_fur_small.png",
	groups = {fur = 1},
})

minetest.register_craftitem("mobehavior:fur_medium", {
	description = "Medium Fur",
	inventory_image = "mobehavior_fur_medium.png",
	groups = {fur = 2},
})

minetest.register_craftitem("mobehavior:fur_large", {
	description = "Large Fur",
	inventory_image = "mobehavior_fur_large.png",
	groups = {fur = 3},
})

minetest.register_craftitem("mobehavior:bone", {
	description = "Bone",
	inventory_image = "mobehavior_bone.png",
	groups = {bone = 1},
})

minetest.register_craftitem("mobehavior:horn", {
	description = "Horn",
	inventory_image = "mobehavior_horn",
	groups = {horn = 1},
})

minetest.register_craftitem("mobehavior:meat", {
	description = "Meat (Raw)",
	inventory_image = "mobehavior_meat.png",
	groups = {meat = 1, raw_meat = 1},
})

minetest.register_craftitem("mobehavior:meat_on_bone", {
	description = "Meat (Raw)",
	inventory_image = "mobehavior_meat_on_bone.png",
	groups = {meat = 1, raw_meat = 1},
})

minetest.register_craftitem("mobehavior:meat_cooked", {
	description = "Meat (Cooked)",
	inventory_image = "mobehavior_meat_cooked.png",
	groups = {meat = 1, cooked_meat = 1},
	on_use = minetest.item_eat(2),
})

minetest.register_craftitem("mobehavior:meat_cooked_on_bone", {
	description = "Meat (Cooked)",
	inventory_image = "mobehavior_meat_cooked_on_bone.png",
	groups = {meat = 1, cooked_meat = 1},
	on_use = minetest.item_eat(2),
	-- TODO: add a bone to inventory after eating
	-- TODO: craft to cut meat off bone
	
})

minetest.register_craftitem("mobehavior:meat_rotten", {
	description = "Meat (Rotten)",
	inventory_image = "mobehavior_meat_rotten.png",
	groups = {meat = 1, rotten_meat = 1},
	on_use = minetest.item_eat(-2), 
})

minetest.register_craft({
	type = 'cooking',
	output = "mobehavior:meat_cooked",
	recipe = "mobehavior:meat",
	cooktime = 10,
})

