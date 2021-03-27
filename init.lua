mn = "mobehavior";
local path = minetest.get_modpath(mn)


mobehavior = {
	registered_projectiles = {},
}



local mod_storage = minetest.get_mod_storage()
 
local storagedata = mod_storage:to_table() -- Assuming there are only messages in the mod configuration
--print("storage data: \n")
--print(dump(storagedata))

if storagedata ~= nil and false then
	--print("loading group data... " .. storagedata.fields.data)
	mobehavior = minetest.deserialize(storagedata.fields.data)
	--print(dump(giants))
end

if mobehavior.groupData == nil then 
	
	mobehavior.groupData= {}
	mobehavior.mobsAlive= {}
end

local saveModData = function() 
	--print("saving group data: \n")
	--print(dump(giants))
	--mod_storage:from_table(giants)
	mod_storage:set_string("data", minetest.serialize(mobehavior))
end

minetest.register_on_shutdown(saveModData)



function vcopy(p) 
	return {x=p.x, y=p.y, z=p.z}
end


mobs = {} -- bootstrap
mobs.mod = "smart"


-- temp

mobs.spawning_mobs = {}

-- Spawn Egg
function mobs:register_egg(mob, desc, background, addegg)

	local invimg = background

	if addegg == 1 then
		invimg = invimg .. "^mobs_chicken_egg.png"
	end

	minetest.register_craftitem(mob, {

		description = desc,
		inventory_image = invimg,

		on_place = function(itemstack, placer, pointed_thing)

			local pos = pointed_thing.above

			if pos
			--and within_limits(pos, 0)
			and not minetest.is_protected(pos, placer:get_player_name()) then

				pos.y = pos.y + 1

				local mob = minetest.add_entity(pos, mob)
				local ent = mob:get_luaentity()

				if ent.type ~= "monster" then
					-- set owner and tame if not monster
					ent.owner = placer:get_player_name()
					ent.tamed = true
				end

				-- if not in creative then take item
				if not creative then
					itemstack:take_item()
				end
			end

			return itemstack
		end,
	})
end
-- end temp


-- Mob Api

dofile(path.."/projectiles.lua")


-- new api from scratch
dofile(path.."/api_fast.lua")

dofile(path.."/items.lua")
-- dofile(path.."/api.lua")
dofile(path.."/behavior.lua")
-- dofile(path.."/simple_api.lua")


dofile(path.."/scripts/init.lua")
dofile(path.."/entities.lua")
dofile(path.."/giant.lua")

dofile(path.."/spawning.lua") 




-- Mob Items
--dofile(path.."/crafts.lua")

-- Spawner
--dofile(path.."/spawner.lua")

print ("[MOD] mobehavior loaded")
