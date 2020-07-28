

set_velocity = function(self, v)

	local x = 0
	local z = 0

	if v and v ~= 0 then

		local yaw = (self.object:getyaw() + self.rotate) or 0

		x = math.sin(yaw) * -v
		z = math.cos(yaw) * v
	end

	self.object:setvelocity({
		x = x,
		y = self.object:getvelocity().y,
		z = z
	})
end


set_velocity2 = function(self, v, up)

	local x = 0
	local z = 0

	if v and v ~= 0 then

		local yaw = (self.object:getyaw() + self.rotate) or 0

		x = math.sin(yaw) * -v
		z = math.cos(yaw) * v
	end

	local y
	if up then
		y = up
	else
		y = self.object:getvelocity().y
	end
	
	self.object:setvelocity({
		x = x,
		y = y,
		z = z
	})
end




set_animation = function(self, type)

	if not self.animation then
		return
	end

	self.animation.current = self.animation.current or ""

	if type == "stand"
	and self.animation.current ~= "stand" then

		if self.animation.stand_start
		and self.animation.stand_end
		and self.animation.speed_normal then

			self.object:set_animation({
				x = self.animation.stand_start,
				y = self.animation.stand_end},

				self.animation.speed_normal, 0)
			self.animation.current = "stand"
		end

	elseif type == "walk"
	and self.animation.current ~= "walk" then

		if self.animation.walk_start
		and self.animation.walk_end
		and self.animation.speed_normal then

			self.object:set_animation({
				x = self.animation.walk_start,
				y = self.animation.walk_end},
				self.animation.speed_normal, 0)

			self.animation.current = "walk"
		end

	elseif type == "run"
	and self.animation.current ~= "run" then

		if self.animation.run_start
		and self.animation.run_end
		and self.animation.speed_run then

			self.object:set_animation({
				x = self.animation.run_start,
				y = self.animation.run_end},
				self.animation.speed_run, 0)

			self.animation.current = "run"
		end

	elseif type == "punch"
	and self.animation.current ~= "punch" then

		if self.animation.punch_start
		and self.animation.punch_end
		and self.animation.speed_normal then

			self.object:set_animation({
				x = self.animation.punch_start,
				y = self.animation.punch_end},
				self.animation.speed_normal, 0)

			self.animation.current = "punch"
		end
	end
end


local function animal_step(self, dtime)
	local btdata = self.btData
-- 			print('newstep')
	local pos = self.object:getpos()
	local yaw = self.object:getyaw() or 0
	
	self.bt_timer = self.bt_timer + dtime
	
	-- run the behavior tree every two seconds
	if self.bt_timer > 2 then
		
		btdata.pos = pos
		btdata.yaw = yaw
		btdata.mob = self
		
-- 		print("\n<<< start >>> ("..math.floor(pos.x)..","..math.floor(pos.z)..")")
			
		-- inventories cannot be serialized and cause the game to crash if
		-- placed in the entity's table
		local inv = minetest.get_inventory({type="detached", name=self.inv_id})
		btdata.inv = inv
		
		bt.tick(self.bt, btdata)
-- 		print("<<< end >>>\n")
		
		-- so clear it out after running the behavior trees
		btdata.inv = nil
		-- the inventory exists on its own
	
		self.bt_timer = 0
	end
	
	
	local rpos = vector.round(pos)
	if not self.node_here or not self.node_below or not vector.equals(self.last_rpos, rpos) then
		
		local here = minetest.get_node({x=rpos.x, y=rpos.y, z=rpos.z})
		local below = minetest.get_node({x=rpos.x, y=rpos.y-2, z=rpos.z})
		
		self.node_here = here.name
		self.node_below = below.name
-- 		print("below: ".. self.node_below)
		
		self.last_rpos = rpos
	end
	
	
	-- handle movement
	
	local v = self.object:getvelocity()
	
	-- TODO: floating
	
	local bdef = minetest.registered_nodes[self.node_below]

	if minetest.registered_nodes[self.node_here].drawtype == "liquid" then
-- 		print("in liquid")
		self.object:setacceleration({ -- float
			x = 0,
			y = 1,
			z = 0
		})
		
	elseif bdef.climbable or bdef.drawtype == "liquid" then
		self.object:setacceleration({
			x = 0,
			y = 0,
			z = 0
		})
		local v = self.object:getvelocity()
		self.object:setvelocity({x=v.x, y=0, z=v.z})
	else
		self.object:setacceleration({
			x = 0,
			y = self.fall_speed,
			z = 0
		})
	end
	
	-- TODO: fall damage
	
	self.jump_timer = self.jump_timer + dtime
	
	
	if self.destination ~= nil then
		
		self.walk_timer = self.walk_timer + dtime
		
		--print("destination ")
		
		local tdist = distance3(pos, btdata.lastpos)
		local dist2 = distance(pos, self.destination)
		-- print("walk dist ".. dist)
		local s = self.destination
		local vec = {
			x = pos.x - s.x,
			y = pos.y - s.y,
			z = pos.z - s.z
		}
		
		
		if tdist < self.walk_velocity * dtime * .9 and self.walk_timer > 1 then
			
			if self.jump_timer > 4 then
				local v = self.object:getvelocity()

				v.y = self.jump_height + 1
				v.x = v.x * 2.2
				v.z = v.z * 2.2

				self.object:setvelocity(v)
				
				self.jump_timer = 0
			end
		end
		
		
		yaw = (math.atan2(vec.z, vec.x) + math.pi / 2) - self.rotate
		self.object:setyaw(yaw)

		
		if dist2 < (self.approachDistance or .1) then
				
			-- we have arrived
			self.destination = nil
			self.walk_timer = 0
			
			-- TODO: make sure this doesn't lead to infinite loops
			-- bump bttimer to get new directions
			self.bt_timer = 99
			
			set_velocity(self, 0)
			set_animation(self, "stand")
			
		else
			
			-- TODO look at dy/dxz and see if we need to try to go up
			if dist2 < (self.approachDistance or .1) then
				set_velocity(self, 0, self.walk_velocity)
			else
				set_velocity(self, self.walk_velocity)
				set_animation(self, "walk")
			end
		end
	end
	
	btdata.lastpos = pos

end


local function npc_step(self, dtime)
	local btdata = self.btData
-- 			print('newstep')
	local pos = self.object:getpos()
	local yaw = self.object:getyaw() or 0
	
	self.bt_timer = self.bt_timer + dtime
	
	-- run the behavior tree every two seconds
	if self.bt_timer > 2 then
		
		btdata.pos = pos
		btdata.yaw = yaw
		btdata.mob = self
		
		print("\n<<< start >>> ("..math.floor(pos.x)..","..math.floor(pos.z)..")")
			
		-- inventories cannot be serialized and cause the game to crash if
		-- placed in the entity's table
		local inv = minetest.get_inventory({type="detached", name=self.inv_id})
		btdata.inv = inv
		
		bt.tick(self.bt, btdata)
		print("<<< end >>>\n")
		
		-- so clear it out after running the behavior trees
		btdata.inv = nil
		-- the inventory exists on its own
	
		self.bt_timer = 0
	end
	
	
	local rpos = vector.round(pos)
	if not vector.equals(self.last_rpos, rpos) then
		
		local below = minetest.get_node({x=rpos.x, y=rpos.y-2, z=rpos.z})
		
		self.node_below = below.name
		print("below: ".. self.node_below)
		
		self.last_rpos = rpos
	end
	
	
	-- handle movement
	
	local v = self.object:getvelocity()
	
	-- TODO: floating
	

	if minetest.registered_nodes[self.node_below].climbable then
		self.object:setacceleration({
			x = 0,
			y = 0,
			z = 0
		})
	else
		self.object:setacceleration({
			x = 0,
			y = self.fall_speed,
			z = 0
		})
	end
	
	-- TODO: fall damage
	
	self.jump_timer = self.jump_timer + dtime
	
	
	if self.destination ~= nil then
		
		self.walk_timer = self.walk_timer + dtime
		
		--print("destination ")
		
		local tdist = distance3(pos, btdata.lastpos)
		local dist2 = distance(pos, self.destination)
		local dist3 = distance3(pos, self.destination)
		-- print("walk dist ".. dist)
		local s = self.destination
		local vec = {
			x = pos.x - s.x,
			y = pos.y - s.y,
			z = pos.z - s.z
		}
		
		
		if tdist < self.walk_velocity * dtime * .9 and self.walk_timer > 1 then
			
			-- try to go up first
			local n = minetest.get_node(pos)
			print("node: "..n.name)
			if minetest.registered_nodes[n.name].climbable then
				print("going up")
				set_velocity2(self, 0, 3--[[self.walkvelocity]])
			
			elseif self.jump_timer > 4 then
				local v = self.object:getvelocity()

				v.y = self.jump_height + 1
				v.x = v.x * 2.2
				v.z = v.z * 2.2

				self.object:setvelocity(v)
				
				self.jump_timer = 0
			end
		end
		
		
		yaw = (math.atan2(vec.z, vec.x) + math.pi / 2) - self.rotate
		self.object:setyaw(yaw)

		
		if dist3 < (self.approachDistance or .1) then
				
			-- we have arrived
			self.destination = nil
			self.walk_timer = 0
			
			-- TODO: make sure this doesn't lead to infinite loops
			-- bump bttimer to get new directions
			self.bt_timer = 99
			
			set_velocity(self, 0)
			set_animation(self, "stand")
			
		elseif 1 == 0 then
			print("alt")
			-- TODO look at dy/dxz and see if we need to try to go up
			if dist2 < (self.approachDistance or .1) then
				set_velocity(self, 0, self.walk_velocity)
			else
				set_velocity(self, self.walk_velocity)
				set_animation(self, "walk")
			end
		end
	end
	
	btdata.lastpos = pos

end






function mobehavior:register_mob_fast(name, def)
	local step
	
	if def.climbs_ladders then
		step = npc_step
	else
		step = animal_step
	end
	
	local mdef = {
		hp = 14,
		rotate = 0,
		reach = 3,
		physical = true,
		weight = 5,
		jump_height = 6,
		collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
		visual = "mesh",
		visual_size = {x=1, y=1},
		mesh = "model",
		fall_speed = -9.81,
		textures = {}, -- number of required textures depends on visual
		colors = {}, -- number of required colors depends on visual
		spritediv = {x=1, y=1},
		initial_sprite_basepos = {x=0, y=0},
		is_visible = true,
		makes_footstep_sound = false,
		automatic_rotate = false,
		
		bt_timer = 0,
		bt = nil,
		btData = nil,
		
		last_rpos = {x=99999999, y=9999999999, z=99999999},
		node_below = "air",
		
		jump_timer = 0,
		walk_timer = 0,

		on_death = function(self, killer)
-- 			print("died")
			local p = self
			local obj = self.object
			if not p then return end
			
			local drops = p.drops
			if not drops then return end
			
			local pos = obj:get_pos()
			
			if type(drops) == "string" then
				minetest.add_item(pos, drops)
				return
			end
			
			local total = 0
			for _,d in ipairs(drops) do
				if type(d) == string then
					minetest.add_item(pos, d)
				else
					if 1 == math.random(d.chance or 1) then
						minetest.add_item(pos, {name=d.name, count=d.min + math.random(d.max-d.min)})
					end
				end
			end
			
		end,
		
		on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
-- 			print("punched")
		end,
		
		on_step = step,
			
		on_activate = function(self, staticdata, dtime_s)
			self.btData = {
				groupID = "default",
				
				waypoints= {},
				paths= {},
				counters={},
				
				history={},
				history_queue={},
				history_depth=20,
				
				posStack={},
			}
			
			local btdata = self.btData
			
			self.inv_id= name..":"..math.random(1, 2000000000)
			--print(btdata.id)
			
			btdata.lastpos = self.object:getpos()
			btdata.last_rpos = vector.round(self.object:getpos())
		
			if type(def.pre_activate) == "function" then
				def.pre_activate(self, static_data, dtime_s)
			end
		
			-- load entity variables
			if staticdata then

				local tmp = minetest.deserialize(staticdata)

				if tmp then

					for _,stat in pairs(tmp) do
						self[_] = stat
					end
				end
			else
				self.object:remove()

				return
			end

			local inventory = minetest.create_detached_inventory(self.inv_id, {})
			inventory:set_size("main", 9)

			
			-- select random texture, set model and size
			if not self.base_texture then

				self.base_texture = def.textures[math.random(1, #def.textures)]
				self.base_mesh = def.mesh
				self.base_size = self.visual_size
				self.base_colbox = self.collisionbox
			end

			-- set texture, model and size
			local textures = self.base_texture
			local mesh = self.base_mesh
			local vis_size = self.base_size
			local colbox = self.base_colbox

			-- specific texture if gotten
			if self.gotten == true
			and def.gotten_texture then
				textures = def.gotten_texture
			end

			-- specific mesh if gotten
			if self.gotten == true
			and def.gotten_mesh then
				mesh = def.gotten_mesh
			end

			-- set child objects to half size
			if self.child == true then

				vis_size = {
					x = self.base_size.x / 2,
					y = self.base_size.y / 2
				}

				if def.child_texture then
					textures = def.child_texture[1]
				end

				colbox = {
					self.base_colbox[1] / 2,
					self.base_colbox[2] / 2,
					self.base_colbox[3] / 2,
					self.base_colbox[4] / 2,
					self.base_colbox[5] / 2,
					self.base_colbox[6] / 2
				}
			end

			if not self.health or self.health == 0 then
				self.health = math.random(self.hp_min, self.hp_max)
			end
			
			self.object:set_hp(self.health)
			
			
			if type(self.armor) == "table" then
				self.object:set_armor_groups(self.armor)
			else
				self.object:set_armor_groups({fleshy = self.armor})
			end
			
			self.old_y = self.object:getpos().y
			self.object:setyaw(math.random(1, 360) / 180 * math.pi)
	-- 		self.sounds.distance = (self.sounds.distance or 10)
			self.textures = textures
			self.mesh = mesh
			self.collisionbox = colbox
			self.visual_size = vis_size

			-- set anything changed above
			self.object:set_properties(self)
-- 			update_tag(self)
			
			if type(def.post_activate) == "function" then
				def.post_activate(self, static_data, dtime_s)
			end
		end,

		get_staticdata = function(self)

			-- remove mob when out of range unless tamed
			if mobs.remove
			and self.remove_ok
			and not self.tamed then

				--print ("REMOVED", self.remove_ok, self.name)

				self.object:remove()

				return nil
			end

			self.remove_ok = true
			self.attack = nil
			self.following = nil
			self.state = "stand"
			
			if self.btData ~= nil then
				self.btData.inv = nil -- just in case
				self.btData.mob = nil -- just in case
				self.btData.targetEntity = nil -- just in case
			end
			

			local tmp = {}

			for _,stat in pairs(self) do

				local t = type(stat)

				if  t ~= 'function'
				and t ~= 'nil'
				and t ~= 'userdata' then
					tmp[_] = self[_]
				end
			end

			-- print('===== '..self.name..'\n'.. dump(tmp)..'\n=====\n')
			return minetest.serialize(tmp)
		end,
		
	}
	
	
	
	for k,v in pairs(def) do
		mdef[k] = v
	end
	
	
	minetest.register_entity(name, mdef)
end


















