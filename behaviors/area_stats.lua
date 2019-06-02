



local type_lookup = {}

for name,def in pairs(minetest.registered_nodes) do
	if def.groups.soil then
		type_lookup[minetest.get_content_id(name)] = 1 -- 1 is "ground"
	elseif def.groups.cracky then
		type_lookup[minetest.get_content_id(name)] = 1 -- cracky things are part of the ground
	elseif def.groups.sand then
		type_lookup[minetest.get_content_id(name)] = 1 
	elseif def.groups.crumbly then
		type_lookup[minetest.get_content_id(name)] = 1 -- gravel, clay, snow, etc
		
	elseif def.groups.choppy then
		type_lookup[minetest.get_content_id(name)] = 0 -- trees, wood, etc
	elseif def.groups.snappy then
		type_lookup[minetest.get_content_id(name)] = 0 -- grass, leaves, etc
	elseif def.groups.fleshy then
		type_lookup[minetest.get_content_id(name)] = 0 -- apples
	elseif def.groups.liquid then
		type_lookup[minetest.get_content_id(name)] = 0 -- water, lava
	end
	
end

type_lookup[minetest.get_content_id("air")] = 0





bt.register_action("AreaIsFlat", {
	tick = function(node, data)
		if not data.targetPos then 
			return "failed" 
		end
		data.targetPos = vector.floor(data.targetPos)
		
		local mmin = vector.add(node.min, data.targetPos) 
		local mmax = vector.add(node.max, data.targetPos) 

-- 		local x1 = node.max.x + data.targetPos.x
-- 		local y1 = node.max.y + data.targetPos.y
-- 		local z1 = node.max.z + data.targetPos.z
-- 		local x0 = node.min.x + data.targetPos.x
-- 		local y0 = node.min.y + data.targetPos.y
-- 		local z0 = node.min.z + data.targetPos.z
		
		local vm = minetest.get_voxel_manip()
		local emin, emax = vm:read_from_map(
			mmin, 
			mmax 
		)
		local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
		local data = vm:get_data()
		print(dump(emin))
		print(dump(emax))
		
		local x1 = mmax.x -- node.min.x
		local y1 = mmax.y -- node.min.y
		local z1 = mmax.z -- node.min.z
		local x0 = mmin.x
		local y0 = mmin.y
		local z0 = mmin.z
		
		function ind(x, y, z)
			local i = (z * area.zstride) + (y * area.ystride) + x + 1
			return math.floor(i)
		end
		
		
		local deltas = {}
		local last_y = (y1 + y0) / 2
		local total_found = 0
		local mean = 0
		local total_missing = 0
-- 		print(x1 .. " " .. y1 .. " " ..z1 )
		for z = z0, z1 do -- for each xy plane progressing northwards
			for x = x0, x1 do -- for each node do
				
				local y = math.floor(y1 / 2)
				local vi = area:index(x, y, z)
				
				
				local t = type_lookup[data[vi]] or 0
-- 				print(t .. " d:" .. data[vi].. " - x: " .. x .. ", y: " .. y .. ", z: " ..z) 
				
				local found = false
				if t == 0 then -- in the air, go down
					while y > y0 do
						y = y - 1
						vi = area:index(x, y, z)
						t = type_lookup[data[vi]] or 0
-- 					print("too high "..y)
-- 						print(t .. " d:" .. data[vi].. " - x: " .. x .. ", y: " .. y .. ", z: " ..z) 
						
						
						if t == 1 then
							-- found the ground
-- 							print(minetest.get_name_from_content_id(data[vi]))
							found = true
							break
						else 
-- 						print(minetest.get_name_from_content_id(data[vi]))
						end
					end
				
 				else -- underground, go up
					
					while y < y1 do
						y = y + 1
						vi = area:index(x, y, z)
-- 					print("too low " .. y)
						t = type_lookup[data[vi] ] or 0
-- 						print(t .. " d:" .. data[vi].. " - x: " .. x .. ", y: " .. y .. ", z: " ..z) 
-- 						print(
						if t == 0 then
							-- found the sky, go back down one
							y = y - 1
							vi = area:index(x, y, z)
-- 							print(minetest.get_name_from_content_id(data[vi]))
							found = true
							break
						else 
-- 						print(minetest.get_name_from_content_id(data[vi]))
						end
					end
				
				end
				
				if found then
				vi = area:index(x, y, z)
-- 				print("----- found " .. data[vi] .. " " ..minetest.get_name_from_content_id(data[vi]))
					last_y = y
					local dy = y - y0 
					deltas[dy] = (deltas[dy] or 0) + 1
					total_found = total_found + 1
					mean = mean + dy
				else
					total_missing = total_missing + 1
-- 				print("--------- missing")
				end
				
			end
		end
		
		print("total_found ".. total_found)
		print("total_missing ".. total_missing)
		print(dump(deltas))
		mean = mean / total_found
		
		local variance = 0
		for k,v in pairs(deltas) do
			local d = mean - k
			variance = variance + (d * d)
		end
		
		variance = variance / total_found
		
		print("variance: ".. variance)
		if variance > node.max_variance then
			return "failed"
		end
		
		return "success"
	end,
	
	ctor = function(min, max, max_variance)
		return {
			min = min,
			max = max,
			max_variance = max_variance,
		}
	end,
})












