



function mobehavior:register_projectile(name, _def)
	
	local def = table.copy(_def)
	
	mobehavior.registered_projectiles[name] = def
	
	
	local mdef = {
		
		
		initial_properties = {
			hp = 1,
			physical = true,
			collisionbox = def.collisionbox or {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
			selectionbox = def.selectionbox or {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
			visual = "mesh",
			visual_size = def.visual_size or 1,
			mesh = def.mesh,
			textures = def.textures,
			is_visible = true,
			max_lifetime = def.max_lifetime or (60 * 5), -- default 5 minute lifetime
			--collide_with_objects = false,
		},
--		use_texture_alpha = "clip",
		
		on_step = function(self, dtime, mr)
			self.timer = self.timer + dtime
			
			if self.timer > def.max_lifetime then
				self.object:remove()
				return
			end
			
			
			if self.stopped ~= nil then
				return
			end
			
			-- orient the model along the flight path
			if def.stable_flight then
				local v = vector.dir_to_rotation(self.object:get_velocity())
				if v ~= nil then
					self.object:set_rotation(v)
				end
			end
			
			if mr.collisions ~= nil and #mr.collisions > 0 then
			--	self.object:remove()
			--	print("arrow died")
			--	print(dump(mr.collisions))
				
			
				for _,cd in ipairs(mr.collisions) do
					self.object:set_velocity({x=0,y=0,z=0})
					self.object:set_acceleration({x=0,y=0,z=0})
					
					if def.persist then
						self.object:set_rotation(
							vector.dir_to_rotation(cd.old_velocity)
						)
					end
					
					self.stopped = true
					
					
					if cd.type == "object" and def.damage ~= nil then
						cd.object:punch(self.object, 1.0, {
							full_punch_interval = 1.0,
							damage_groups = def.damage,
						}, nil)
					end
					
					
			
					if def.on_hit then
						local ret = def.on_hit(self, cd)
						if ret ~= nil and ret == false then
							break;
						end
					end
					
					
				end 
				
				if not def.persist then
					self.object:remove()
				end
			end
		end,
		
		on_activate = function(self, staticdata)
			self.object:set_armor_groups({immortal = 1, punch_operable = 1})
			
			if staticdata then
				local tmp = minetest.deserialize(staticdata)

				if tmp then
					for _,stat in pairs(tmp) do
						self[_] = stat
					end
				end
			end
			
			self.timer = self.timer or 0
			
			if self._velocity ~= nil then
				self.object:set_velocity(self._velocity)
			end
			
			--if self._animation ~= nil then
			--	set_animation(self, self._animation)
			--end
			
			if self._rotation ~= nil then
				self.object:set_rotation(self._rotation)
			else
				self.object:set_yaw(math.random(1, 360) / 180 * math.pi)
			end
		end,
		
		get_staticdata = function(self)
			local tmp = {}

			for _,stat in pairs(self) do
				local t = type(stat)

				if  t ~= 'function'
				and t ~= 'nil'
				and t ~= 'userdata' then
					tmp[_] = self[_]
				end
			end
			
			tmp._velocity = self.object:get_velocity()
			tmp._rotation = self.object:get_rotation()
			--tmp._animation = self.animation.name

			return minetest.serialize(tmp)
		end,
		
		on_death = function(self)
		print("died")
			return true
		end,
		
		on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
			self.object:remove()
			print("punched")
			return true
		end,
	}


	minetest.register_entity(name, mdef)
end



function mobehavior:fire_projectile(name, pos, dir, speed)
	local obj = minetest.add_entity(pos, name)
	
	local dir2 = vector.normalize(dir)
	local v = vector.multiply(dir2, speed)
	
	obj:set_velocity(v)
	obj:set_acceleration({x=0, y=-9.81, z=0})
end



function targeting(range, height, speed) 
	
	local c = height * height + range * range
	local b = -9.81 * height - speed * speed
	local a = -9.81 * -9.81 * 0.25
	local t_l = math.sqrt((-b - math.sqrt(b * b - 4 * a * c)) / (2 * a)) 
	local t_h = math.sqrt((-b + math.sqrt(b * b - 4 * a * c)) / (2 * a)) 
	print("c: "..c)
	print("b: "..b)
	print("a: "..a)
	print("l: "..t_l)
	print("h: "..t_h)
	local theta_l = math.acos(range / (t_l * speed))
	local theta_h = math.acos(range / (t_h * speed))

	local v_xl = range / t_l
	local v_yl = math.sqrt(speed * speed - v_xl * v_xl)
	
	local v_xh = range / t_h
	local v_yh = math.sqrt(speed * speed - v_xh * v_xh)

	return v_xl, v_yl, v_xh, v_yh
--	return theta_l, theta_h
end

function mobehavior:fire_projectile_at(name, pos, target)
	local obj = minetest.add_entity(pos, name)
	local range = target.x - pos.x
	local height = pos.y - target.y	
	
	local speed = 39
	--local l, h = targeting(range, height, speed)
	local xl, yl, xh, yh = targeting(range, height, speed)
--	local dir2 = vector.normalize(vector.subtract(target, pos))
--	local v = vector.multiply(dir2, speed)
	
	obj:set_velocity({
		--x = math.cos(l) * speed,
		--y = math.sin(l) * speed,
		x = xl,
		y = yl,
		z = 0
	})
	obj:set_acceleration({x=0, y=-9.81, z=0})
end



mobehavior:register_projectile("mobehavior:test_arrow", {
	visual_size = {x=10, y=10},
	mesh = "mobehavior_arrow.obj",
	textures = {"mobehavior_arrow_yellow.png"},
	collisionbox = {-0.01,-0.01,-0.01, 0.01,0.01,0.01},
	selectionbox = {-0.2,-0.2,-0.2, 0.2,0.2,0.2},
		
	max_lifetime = 60,
	persist = 1,
	stable_flight = 1,
	damage = {fleshy = 1},
	
	on_hit = function(self, cd)
	
		if cd.type == "node" then
			--minetest.set_node(cd.node_pos, {name="default:coalblock"})
		end
	end
})


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
	use_texture_alpha = "clip",
})


minetest.register_abm({
	nodenames = {"mobehavior:arrow_tester"},
	interval = 1,
	chance = 1,
	catch_up = false,

	action = function(pos)
			pos.y= pos.y + 1
			
			mobehavior:fire_projectile("mobehavior:test_arrow", pos, {x=1, y=.55, z = 0}, 20)
			--[[
			print("firing")
			for n = 1,50 do
				local x = math.random(-100,100)
				local z = math.random(-100,100)
				local d  = vector.normalize({x=x, y=120, z = z})
				mobehavior:fire_projectile(
					"mobehavior:test_arrow", vector.add(pos, d), d, 9)
			end
			]]
	end,
})
