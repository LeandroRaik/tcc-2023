---##  Wave Function Collapse  ##---

--[[

-Use the function wfc_init to create data structure
-Use the function wfc_step to run the next iteration of wfc


--]]



----- PRINTING ------------------------------------

local function print_map(matrix)
  print('\n--------  MAP  --------\n')
  
  for i=1, #matrix do
    for j=1, #matrix[i] do
      io.write(matrix[i][j], ' ')
    end
    print()
  end
  print()
end


local function print_tile_count(data)
  print('----- SAMPLE TILE COUNT -----\n')
  for i=1, #data.tile_count do
    print(tostring(i) .. ' => ' .. tostring(data.tile_count[i]))
  end
  print()
end


local function print_rules(data)
  print('RULES:')
  for i=1, data.n_tiles do
    print('\n----- TILE ' .. tostring(i) .. ' ------\n')
    for k, v in pairs(data.rule_set[i]) do
      io.write(string.upper(k) .. ': ')
      for kk, vv in pairs(data.rule_set[i][k]) do
        io.write(vv, ' ')
      end
      print()
    end
  end
  print()
end


local function print_entropy_values(data)
  for k, v in pairs(data.entropy_map) do
    for kk, vv in pairs(data.entropy_map[k]) do
      --print(data.entropy_map[k][kk])
      for l=1, #vv do
        print(vv[l])
      end
    end
    print()
  end
end



local function print_entropy_map(data)
  local pad = '' 

  print('----- ENTROPY MAP -----\n')
  for k, v in pairs(data.entropy_map) do
    for kk, vv in pairs(data.entropy_map[k]) do
      if #data.entropy_map[k][kk] < 10 then
        pad = '0'
      else
        pad = ''
      end
      io.write(pad .. tostring(#data.entropy_map[k][kk]), ' ')
    end
    print()
  end
end

-----  SUPPORT FUNCTIONS  -------------------------

local function sleep(seconds)
  if not (package.config:sub(1,1) == '\\') then
    os.execute("sleep " .. seconds)
  else
    os.execute("timeout /t" .. seconds .. "/nobreak")
  end
end



local function table_contains(table, val)
  local found = false
  for i=1, #table do
    if table[i] == val then
      found = true
      break
    end
  end 
  return found
end


local function get_sample(mode)
 local sample = {
    {1,2,2,1},
    {3,2,3,3},
    {1,4,2,5},
    {5,2,2,1},
  }

  if mode == 'sample' then
    return sample
  elseif mode == 'load' then
    print('LOADING..')
    os.exit()
  end

  return nil
end


local function start_random_map(data)
  local i = math.random(1, data.map_len)
  local j = math.random(1, data.map_wid)
  local tile = math.random(1, data.n_tiles)
  data.map[i][j] = tile
end


local function create_new_map(len, wid)
  local map = {} 
  for i=1, len do
    map[i] = {}
    for j=1, wid do
      map[i][j] = 0 
    end
  end
  return map
end


function create_entropy_map(data)
  local map = {}
  for i=1, data.map_len do
    map[i] = {}
    for j=1, data.map_wid do
      map[i][j] = {}
      if data.map[i][j] == 0 then
        for t=1, data.n_tiles do
          table.insert(map[i][j], t)
        end
      end
    end
  end
  return map
end


local function is_map_ok(data)
  local result = true 

  for i=1, #data.map do
    for j=1, #data.map[i] do
      if data.map[i][j] == 0 then
        result = false
        break
      end
    end
  end

  return result

end

-----  RULES  ---------------------------------------

local function get_neighbor(dir, c_tile, data, i, j)
  local neighbor = nil

  if dir == 'up' then
    if i-1 > 0 then
      neighbor = data.sample[i-1][j] 
    end
  elseif dir == 'down' then
    if i+1 <= #data.sample then
      neighbor = data.sample[i+1][j]
    end
  elseif dir == 'left' then
    if j-1 > 0 then
      neighbor = data.sample[i][j-1]
    end
  else -- right
    if j+1 <= #data.sample[i] then
      neighbor = data.sample[i][j+1]
    end
  end

  --Check if is a valid neighbor and check if its not 
  --already that rule for this tile (avoid duplicates)
  if neighbor ~= nil then
    if not table_contains(data.rule_set[c_tile][dir], neighbor) then
      table.insert(data.rule_set[c_tile][dir], neighbor)
    end
  end
end


local function get_rules(data)
  local c_tile = nil

  --Create a place to store each tile rule
  for i=1, data.n_tiles do
    data.rule_set[i] = {
      up = {},
      down = {},
      right = {},
      left = {}
    }
  end


  for i=1, #data.sample do
    for j=1, #data.sample[i] do
      c_tile = data.sample[i][j] 

      --Sum to get the total times the tile appear on the sample
      data.tile_count[c_tile] = data.tile_count[c_tile] + 1

      --Get neghbors to add to rule set
      get_neighbor('up', c_tile, data, i, j)
      get_neighbor('down', c_tile, data, i, j)
      get_neighbor('left', c_tile, data, i, j)
      get_neighbor('right', c_tile, data, i, j)
    end
  end
  
  --sort numeric
  for i=1, data.n_tiles do
    table.sort(data.rule_set[i]['up'])
    table.sort(data.rule_set[i]['down'])
    table.sort(data.rule_set[i]['left'])
    table.sort(data.rule_set[i]['right'])
  end
end

-----  ENTROPY  ------------------------------------

local function get_entropy_table(c_entropy, r_entropy)
  local entropy_table = {}

  if #c_entropy < #r_entropy then
    for i=1, #c_entropy do
      if table_contains(r_entropy, c_entropy[i]) then
        table.insert(entropy_table, c_entropy[i])
      end
    end
  else
    for i=1, #r_entropy do
      if table_contains(c_entropy, r_entropy[i]) then
        table.insert(entropy_table, r_entropy[i])
      end
    end
  end

  return entropy_table
end


local function update_neighbors_entropy(data, i, j)
  local c_tile = data.map[i][j]
  local rule_up = data.rule_set[c_tile]['up']
  local rule_down = data.rule_set[c_tile]['down']
  local rule_left = data.rule_set[c_tile]['left']
  local rule_right = data.rule_set[c_tile]['right']

  --TILE UP
  if i-1 > 0 then --is inside the map grid
   if data.map[i-1][j] == 0 then --is not collapse
    if #data.entropy_map[i-1][j] ~= data.n_tiles then --have less possibilities
      --Join commom rules
      data.entropy_map[i-1][j] = get_entropy_table(data.entropy_map[i-1][j], rule_up) 
    else 
      data.entropy_map[i-1][j] = rule_up
    end
   end
  end

  --TILE DOWN
  if i+1 < #data.map then
    if data.map[i+1][j] == 0 then
      if #data.entropy_map[i+1][j] ~= data.n_tiles then
        data.entropy_map[i+1][j] = get_entropy_table(data.entropy_map[i+1][j], rule_down)
      else
        data.entropy_map[i+1][j] = rule_down
      end
    end
  end

  --TILE LEFT
  if j-1 > 0 then
    if data.map[i][j-1] == 0 then
      if #data.entropy_map[i][j-1] ~= data.n_tiles then
        data.entropy_map[i][j-1] = get_entropy_table(data.entropy_map[i][j-1], rule_left)
      else
        data.entropy_map[i][j-1] = rule_left
      end
    end
  end

  --TILE RIGHT
  if j+1 <= #data.map[i] then
    if data.map[i][j+1] == 0 then
      if #data.entropy_map[i][j+1] ~= data.n_tiles then
        data.entropy_map[i][j+1] = get_entropy_table(data.entropy_map[i][j+1], rule_right)
      else
        data.entropy_map[i][j+1] = rule_right
      end
    end
  end

end


local function update_entropy_map(data)
  for i=1, #data.map do
    for j=1, #data.map[i] do
      if data.map[i][j] ~= 0 then
        update_neighbors_entropy(data, i, j)
      end
    end
  end
end


----- COLLAPSE --------------------------------------

local function choose_new_tile(data, best_tiles)
  --Maybe add some override over the purely random?
  local tile_pos = best_tiles[math.random(1,#best_tiles)]
  local rules = data.entropy_map[tile_pos[1]][tile_pos[2]]
  local new_tile = rules[math.random(1,#rules)]

  --Update map with the new tile
  data.map[tile_pos[1]][tile_pos[2]] = new_tile
  --Mark tile as collapsed
  data.entropy_map[tile_pos[1]][tile_pos[2]] = {}
end



local function collapse_map(data)
  local min_ent = data.n_tiles + 1
  local best_tiles = {}
  local b_tile = {}

  for i=1, #data.map do
    for j=1, #data.map[i] do
      if #data.entropy_map[i][j] ~= 0 then --not collapsed
        if #data.entropy_map[i][j] < min_ent then
          min_ent = #data.entropy_map[i][j]
          best_tiles = {}
          b_tile = {i, j}
          table.insert(best_tiles, b_tile)
        elseif #data.entropy_map[i][j] == min_ent then
          b_tile = {i, j}
          table.insert(best_tiles, b_tile)
        end
      end
    end
  end

  if #best_tiles > 0 then
    choose_new_tile(data, best_tiles)
    return false 
  else
    return true 
  end

end

----- W.F.C ------------------------------------------

local function wfc(data)
  local done = false
  local count = 1

  while not done do
    print('\n#### LOOP COUNT: ' .. tostring(count) .. ' ####\n')
    update_entropy_map(data)
    print_entropy_map(data)

    done = collapse_map(data)
    print_map(data.map)
    count = count + 1
    --sleep(2)
    io.read()
  end

  if not is_map_ok(data) then
    print('\nFAILED CREATING MAP!\n')
  else
    print('\nSUCCESS CREATING MAP!\n')
  end

end


function do_wfc_step(data, step, debug)
  print('STEP: ' .. tostring(step))
  --Create new entropy map
  update_entropy_map(data)

  if debug then print_entropy_map(data) end

  collapse_map(data)

  if debug then print_map(data.map) end

end


-----  INIT  ----------------------------------------

function wfc_init(m_wid, m_len, num_tiles, t_size, t_sample, s_map, debug)
  --math.randomseed(os.time())
  math.randomseed(420)

  local data =
  {
    n_tiles = num_tiles,
    tile_size = t_size,
    map_wid = m_wid,
    map_len = m_len,
    map = create_new_map(m_len, m_wid),
    sample = t_sample,
    entropy_map = nil,
    start_map = s_map,
    rule_set = {},
    tile_count = {},
  }

  --Used to count how many times a tile appear on a sample
  for i=1, data.n_tiles do
    data.tile_count[i] = 0
  end

  if data.sample ~= nil then
    get_rules(data)
  else
    print("NO SAMPLE DATA, ABORTING..")
    os.exit()
  end

  --If no start map was passed, create one with a random start point.
  if data.start_map == nil then
    data.map = create_new_map(data.map_len, data.map_wid)
    start_random_map(data)
  else
    data.map = data.start_map
  end

  data.entropy_map = create_entropy_map(data)
  update_entropy_map(data)

  if debug then
    print_map(data.sample)
    print_rules(data)
    print_tile_count(data)
    print_entropy_map(data)
    print_map(data.map)
  end

  return data

end



--Old function used by CLI
function full_wfc_loop(wid, len, num_tiles, t_size)
  -- math.randomseed(os.time())
  math.randomseed(420)

  local data =
  {
    n_tiles = num_tiles,
    tile_size = 16,
    map_wid = wid,
    map_len = len,
    map = create_new_map(len, wid),
    sample = nil,
    entropy_map = nil,
    rule_set = {},
    tile_count = {},
  }

  --Used to count how many times a tile appear on a sample
  for i=1, data.n_tiles do
    data.tile_count[i] = 0
  end

  data.sample = get_sample('sample')

  if data.sample ~= nil then
    get_rules(data)
  else
    print('NO SAMPLE DATA, ABORTING..')
    os.exit()
  end

  --Debug print
  print_map(data.sample)
  print_rules(data)
  print_tile_count(data)

  data.map = create_new_map(data.map_len, data.map_wid)

  --Select a first random tile at a random position to start.
  start_random_map(data)

  data.entropy_map = create_entropy_map(data)

  print_entropy_map(data)
  print_map(data.map)

  wfc(data)


end



full_wfc_loop(20, 20, 5, 16)
