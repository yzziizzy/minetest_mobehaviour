



function mobehavior:register_projectile(name, _def)
	
	local def = table.copy(_def)
	
	mobehavior.registered_projectiles[name] = def
	
	local mdef = {
		physical = true,
		collisionbox = {-0.1,-0.1,-0.1, 0.1,0.1,0.1},
		visual = "mesh",
		visual_size = {x=10, y=10},
		mesh = "mobehavior_arrow.obj",
		-- mesh = "mobs_chicken.x",
		textures = {"mobehavior_arrow_yellow.png"},
		is_visible = true,
		
		on_step = function(self, dtime, mr)
			--self.timer = self.timer + dtime
			if self.stopped ~= nil then
				return
			end
			
			--local v = {x=1,y=1,z=1} --self.object:get_velocity()
			local v = vector.dir_to_rotation(self.object:get_velocity())
			if v ~= nil then
				self.object:set_rotation(v)
			end
			
			if mr.collisions ~= nil and #mr.collisions > 0 then
			--	self.object:remove()
			--	print("arrow died")
			--	print(dump(mr.collisions))
			
				for _,cd in ipairs(mr.collisions) do
					self.object:set_velocity({x=0,y=0,z=0})
					self.object:set_acceleration({x=0,y=0,z=0})
					
					self.stopped = true
					
					
					if cd.type == "node"  then
					
						
						--[[
						for x = -4,4 do
						for y = -4,4 do
						for z = -4,4 do
							local o = {x=x,y=y,z=z}
							local p = vector.add(cd.node_pos, o)
							
							if (vector.length(o)) < 2.1 then
								minetest.set_node(p, {name="air"})
							end
						end
						end
						end
						]]
					end
					
					--self.object:remove()
				end
			end

		end,
		
		on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
 			print("punched")
		end,
	}


	for k,v in pairs(def) do
		mdef[k] = v
	end


	minetest.register_entity(name, mdef)
end

mobehavior:register_projectile("mobehavior:test_arrow", {})


minetest.register_node("mobehavior:arrow_tester", {
	tiles = {"default_mese_block.png"},
	description = "Arrow Tester",
	groups = {cracky = 1},
})

minetest.register_node("mobehavior:ar2", {
	drawtype="mesh",
	mesh="mobehavior_arrow.obj",
	visual_size = 10,
	tiles = {"mobehavior_arrow_yellow.png"},
	description = "Arrow 222",
	groups = {cracky = 1},
})


minetest.register_abm({
	nodenames = {"mobehavior:arrow_tester"},
	interval = 4,
	chance = 1,
	catch_up = false,

	action = function(pos)
			pos.y= pos.y + 1
			
			local obj = minetest.env:add_entity(pos, "mobehavior:test_arrow")
			local dir = vector.normalize{x=1, y=.55, z = 0}
			local v = vector.multiply(dir, 20)
			
			obj:set_velocity(v)
			obj:set_acceleration({x=0, y=-9.81, z=0})
	end,
})
