mn = "mobehavior";
local path = minetest.get_modpath(mn)


mobehavior = {}



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
	mobehavior = {
		groupData= {},
		mobsAlive= {},
	}
end

local saveModData = function() 
	--print("saving group data: \n")
	--print(dump(giants))
	--mod_storage:from_table(giants)
	mod_storage:set_string("data", minetest.serialize(mobehavior))
end

minetest.register_on_shutdown(saveModData)


-- Mob Api

dofile(path.."/api.lua")
dofile(path.."/behavior.lua")
dofile(path.."/simple_api.lua")


dofile(path.."/scripts/init.lua")
dofile(path.."/giant.lua") 




-- Mob Items
--dofile(path.."/crafts.lua")

-- Spawner
--dofile(path.."/spawner.lua")

print ("[MOD] mobehavior loaded")
