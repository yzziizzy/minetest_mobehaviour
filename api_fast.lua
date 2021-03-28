
-- check if within map limits (-30911 to 30927)
function within_limits(pos, radius)

	if  (pos.x - radius) > -30913
	and (pos.x + radius) <  30928
	and (pos.y - radius) > -30913
	and (pos.y + radius) <  30928
	and (pos.z - radius) > -30913
	and (pos.z + radius) <  30928 then
		return true -- within limits
	end

	return false -- beyond limits
end


set_velocity = function(self, v)
	self.jumping = false
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
		print("no animation")
		return
	end

	self.animation.current = self.animation.current or ""

	if type == "stand"
	 then

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
	then

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
	 then

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
	 then

		if self.animation.punch_start
		and self.animation.punch_end
		and self.animation.speed_normal then

			self.object:set_animation({
				x = self.animation.punch_start,
				y = self.animation.punch_end},
				self.animation.speed_normal, 0)

			self.animation.current = "punch"
		end
	else
		print("invalid animation ".. self.inv_id)
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


--[[
moveresult = {
        touching_ground = boolean,
        collides = boolean,
        standing_on_object = boolean,
        collisions = {
            {
                type = string, -- "node" or "object",
                axis = string, -- "x", "y" or "z"
                node_pos = vector, -- if type is "node"
                object = ObjectRef, -- if type is "object"
                old_velocity = vector,
                new_velocity = vector,
            },
            ...
        }
    }
]]

local function walk_dest(self, pos)
	local s = self.next_wp
	
	local vec = {
		x = pos.x - s.x,
		y = pos.y - s.y,
		z = pos.z - s.z
	}
	local yaw = (math.atan2(vec.z, vec.x) + math.pi / 2) - self.rotate
	self.object:set_yaw(yaw)
	set_velocity(self, self.walk_velocity)
	
	set_animation(self, "walk")
end




local function npc_step(self, dtime, mr)
	local btdata = self.btData
 --			print('newstep')
	local pos = self.object:get_pos()
	local rpos = {
		x = math.floor(pos.x + 0.5), 
		y = math.floor(pos.y - 0.4), 
		z = math.floor(pos.z + 0.5)
	}
	local bpos = {x = rpos.x, y = rpos.y-1, z= rpos.z}
	
	local pos_yr = {x = pos.x, y = rpos.y, z = pos.z}
	--print(minetest.pos_to_string(pos1) .. " -> " ..minetest.pos_to_string(pos))
	local yaw = self.object:get_yaw() or 0
	
	local standing_on_node = nil
	local standing_on_pos = nil
	local collisions = {}
	
	if mr.standing_on_object == true or mr.touching_ground == true then
		self.jumping = false
	end
	
	--print(dump(mr))
	--print("p.y " .. pos.y..", rp "..minetest.pos_to_string(rpos))
	if type(mr.collisions) == "table" then
		for k,v in pairs(mr.collisions) do
			
			if v.type == "node" then 
				local n = minetest.get_node(v.node_pos)
				
				if bpos.y == v.node_pos.y then
				--	print("standing on "..n.name)
					standing_on_node = n
					standing_on_pos = v.node_pos
					
					
				else
			--		print("coll: "..n.name.." at " .. minetest.pos_to_string(v.node_pos))
					table.insert(collisions, {p = v.node_pos, n = n})
				end
			end
		end
		
	end 
	
	
	
	
	
	self.bt_timer = self.bt_timer + dtime
	--set_animation(self, "walk")
	
	
	
	-- run the behavior tree every two seconds
	if self.run_bt == true and self.bt_timer > 2 then
		
		
		btdata.pos = pos
		btdata.yaw = yaw
		btdata.mob = self
		
		--print("\n<<< start >>> ("..math.floor(pos.x)..","..math.floor(pos.z)..")")
			
		-- inventories cannot be serialized and cause the game to crash if
		-- placed in the entity's table
		local inv = minetest.get_inventory({type="detached", name=self.inv_id})
		btdata.inv = inv
		
		bt.tick(self.bt, btdata)
		--print("<<< end >>>\n")
		
		-- so clear it out after running the behavior trees
		btdata.inv = nil
		-- the inventory exists on its own
	
		self.bt_timer = 0
		
		self.arrived = false
		self.walk_aborted = false
	end
	
	
	-- process new node being stood on
	if not vector.equals(self.last_rpos, rpos) then
		if standing_on_node then
			self.node_below = standing_on_node.name
		else
			self.node_below = "air"
		end
		
		--print("below: ".. self.node_below)
		
			
		self.last_rpos = rpos
		
		
		-- don't fall while on ladders
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
	
	end
	
	
	-- handle movement
	
	local v = self.object:get_velocity()
	
	-- TODO: floating
	

	
	
	-- TODO: fall damage
	
	self.jump_timer = self.jump_timer + dtime
	
	-- handle new destinations
	if self.internal_dest ~= self.destination then
		self.internal_dest = self.destination
		self.last_tdist = nil
		self.arrived = false
		self.run_bt = false
		
		self.wp_list = {}
		table.insert(self.wp_list, self.destination)
		self.next_wp = self.destination
		--print("new destination: ".. minetest.pos_to_string(self.destination))
		walk_dest(self, pos)
	end
	
	
	
	if self.next_wp ~= nil then 
	
		-- target (current waypoint) distance
		local tdist = distance3(pos, self.next_wp)
		if self.last_tdist == nil then
			self.last_tdist = tdist
		end
		
		-- moved distance, since last tick
		local mdist = distance3(pos, self.last_pos)
		--print("tdist "..tdist)
		
		-- reset the stall timer if we moved
		if mdist > (dtime * self.walk_velocity * 0.9) then
			 self.stall_timer = 0
		end	
	
		
		if self.jumping == true then
			-- collisions stop velocity, so keep pushing forward while jumping
			
			local v = self.object:getvelocity()
			
			v.x = -math.sin(yaw) * 2.2
			v.z = math.cos(yaw) * 2.2
		
			self.object:set_velocity(v)
		
		elseif tdist < (self.approachDistance or 0.1) and #self.wp_list <= 1 then
			-- check arrival
			
			if #self.wp_list <= 1 then
				-- arrived at final destination
			--	print("final arrival")
				
				self.destination = nil
				self.internal_dest = nil
				self.wp_list = {}
				self.next_wp = nil
				
				self.arrived = true
				self.run_bt = true
				
				set_velocity(self, 0)
				set_animation(self, "stand")
			--[[	
			elseif tdist <= 0.1 then
				-- arrived at a waypoint
				print("arrived at waypoint")
			
				table.remove(self.wp_list, 1)
				self.next_wp = self.wp_list[1]
				print("  a:next wp: ".. minetest.pos_to_string(self.next_wp))
				
				walk_dest(self, pos)]]
			else
		--		print("unhandled arrival case (#wp_list == ".. #self.wp_list..")"
		--		.. " .. tdist = "..tdist
		--		)
			end
		
		
		elseif self.last_tdist < tdist then 
			-- moving away from the current waypoint
			--  effectively arrived there, but must find the next best one
		--	print("passed waypoint")
			
			-- TODO: check for final arrival
			if #self.wp_list == 1 then
				-- arrived
				
				-- bug: gets stuf f you arrive too far away and the btree does not
				--   run the next cycle. tall stairs with falling near the dest.
				
			--	print("a:final arrival, ".. (tdist - (self.approachDistance or 0.1)) .. " too far")
				--self.jumping = false
				
				self.destination = nil
				self.internal_dest = nil
				self.wp_list = {}
				self.next_wp = nil
				
				self.arrived = true
				self.run_bt = true
				
				set_velocity(self, 0)
				set_animation(self, "stand")
			else
				
				table.remove(self.wp_list, 1)
				self.next_wp = self.wp_list[1]
			--	print("  b:next wp: ".. minetest.pos_to_string(self.next_wp))
					
				walk_dest(self, pos)
			end
			
		elseif mdist < (dtime * self.walk_velocity * 0.9) then
			self.stall_timer = self.stall_timer + dtime
		
			if self.stall_timer > 0.1 then
				-- stalled on something
				-- look for a way around
				--print("stalled")
				self.stall_timer = 0
				
				-- check to see if we can just jump over it
				local should_jump = false
				local vel = self.object:get_velocity()
				local fpos = vector.add(pos, {x = -math.sin(yaw), y = .5, z = math.cos(yaw)})  
				local fnode = minetest.get_node(fpos)
				if fnode and fnode.name == "air" then
					should_jump = true
				end
				--print("fnode: "..(fnode.name) .. " "..dump(fpos))
				
				if should_jump == true then
					if self.jump_timer > 2.0 then
						local v = self.object:getvelocity()
		
						v.y = self.jump_height
						v.x = v.x * 2.2
						v.z = v.z * 2.2
		
						self.object:set_velocity(v)
						
						self.jump_timer = 0
						self.stall_timer = 0
						self.jumping = true
						
			--			print("jumping")
					else
					--	print("waiting to jump")
					end
				else
				
					-- use the pathfinder
					local points = minetest.find_path(
						rpos, self.internal_dest, 10, 1.45, 3, "A*")
						
					if points == nil then
			--			print("failed to find path")
						
						self.walk_aborted = true
						self.wp_list = {}
						self.next_wp = nil
						self.run_bt = true
						
						set_velocity(self, 0)
						set_animation(self, "stand")
						
					else
			--			print("found path ".. minetest.pos_to_string(pos))
						
						self.wp_list = {}
						for k,v in ipairs(points) do
							v.y = v.y + .5
							
							if k > 1 and not (
								v.x == points[k-1].x and
								v.z == points[k-1].z and
								v.y ~= points[k-1].y
								)
							then
								table.insert(self.wp_list, v)
								
								--[[
								print(k.. " - "..minetest.pos_to_string(v));
								minetest.add_particlespawner({
									amount = #points,
									time = .9 * (#points-3),
									minpos = v,
									maxpos = v,
									minvel = {x=-.1, y=-.1, z=-.1},
									maxvel = {x=.1, y=.1, z=.1},
									minacc = {x=0, y=0, z=0},
									maxacc = {x=0, y=0, z=0},
									minexptime = 1.05,
									maxexptime = 1.05,
									minsize = 4.1,
									maxsize = 4.1,
									collisiondetection = false,
									vertical = false,
									texture = "tnt_smoke.png^[colorize:#00ff00:300",
									playername = "singleplayer"
								})
								
							else
								if k > 1 then
									print(" bad wp: ".. 
										minetest.pos_to_string(v) .. " == " ..
										minetest.pos_to_string(points[k-1]))
								end
								]]
							end
							
							
						--	minetest.set_node(v, {name="fire:basic_flame"})
						end
						
						if #self.wp_list == 0 then
				--			print("failed to find acceptable path")
							
							
							self.walk_aborted = true
							self.wp_list = {}
							self.next_wp = nil
							self.run_bt = true
							
							set_velocity(self, 0)
							set_animation(self, "stand")
							
						else
							self.next_wp = self.wp_list[1]
				--			print("c:next wp: ".. minetest.pos_to_string(self.next_wp))
							
							walk_dest(self, pos)
						end
						
						
					end -- found points
					
				end -- should_jump
			else -- stall timer
				--print("stall timer: ".. self.stall_timer)
				--set_animation(self, "stand")
			end -- stall timer
			
		end
		
		
	
		
		if self.next_wp then
			--print("setting last_tdist")
			self.last_tdist = distance3(pos, self.next_wp)
		else
			--print("last_tdist = nil")
			self.last_tdist = nil
		end
	else
		--print("standing debug")
		set_animation(self, "stand")
	end
	
	
	self.last_pos = pos
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
		automatic_rotate = 0,
		
		bt_timer = 0,
		bt = nil,
		btData = nil,
		
		last_rpos = {x=99999999, y=9999999999, z=99999999},
		node_below = "air",
		
		jump_timer = 0,
		walk_timer = 0,

		on_death = function(self, killer)
			print("died")
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
 			print("punched")
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
			
			
			btdata.lastpos = self.object:get_pos()
			btdata.last_rpos = vector.round(self.object:get_pos())
			
			self.walk_timer = 0
			self.stall_timer = 0
			self.destination = nil
			self.internal_dest = nil
			self.wp_list = {}
			self.next_wp = nil
			self.last_pos = btdata.lastpos
			self.last_tdist = nil
			self.arrived = false
			self.walk_aborted = false
			self.run_bt = true
		
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
			
			if self._velocity ~= nil then
				self.object:set_velocity(self._velocity)
			end
			
			if self._animation ~= nil then
				set_animation(self, self._animation)
			end
			
			if self._rotation ~= nil then
				self.object:set_rotation(self._rotation)
			else
				self.object:set_yaw(math.random(1, 360) / 180 * math.pi)
			end
			
			self.old_y = self.object:get_pos().y
			
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
			
			tmp._velocity = self.object:get_velocity()
			tmp._rotation = self.object:get_rotation()
			tmp._animation = self.animation.name

			-- print('===== '..self.name..'\n'.. dump(tmp)..'\n=====\n')
			return minetest.serialize(tmp)
		end,
		
	}
	
	
	
	for k,v in pairs(def) do
		mdef[k] = v
	end
	
	
	minetest.register_entity(name, mdef)
end


















