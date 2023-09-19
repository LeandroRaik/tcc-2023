---##  Wave Function Collapse  ##---


local fail_count = 0

-----  SUPPORT FUNCTIONS  -------------------------

local function sleep(seconds)
  if seconds > 0 then
    if not (package.config:sub(1,1) == '\\') then
      os.execute("sleep " .. seconds)
    else
      os.execute("timeout /t" .. seconds .. "/nobreak")
    end
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


local function start_random_map(data)
  local i = math.random(1, data.map_len)
  local j = math.random(1, data.map_wid)
  local tile = math.random(1, data.n_tiles)
  data.map[i][j] = tile
  local l_rules = {}

  for r=1, data.n_tiles do table.insert(l_rules, r) end
  
  local track = {
    i = i,
    j = j,
    last_tile = tile,
    last_rules = l_rules 
  }

  table.insert(data.map_track, track) 
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


local function reset_map_info(data) end


local function check_flaws(data)
  local flaw = false

  for i=1, #data.map do
    for j=1, #data.map[i] do
      if data.map[i][j] == 0 and #data.entropy_map[i][j] == 0 then
        flaw = true
        data.problem_tile = {i, j}
        break
      end
    end
  end

  if not flaw then data.problem_tile = {} end

  return flaw
        
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
  if i+1 <= #data.map then
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

----- BACKTRACKING ----------------------------------

local function backtrack(data)
  data.backtrack_count = data.backtrack_count + 1
  local track = data.map_track[#data.map_track]
  local ok = false 

  if #data.map_track > 0 then
    --Removes last attempt from old rules
    for i=1, #data.map_track[#data.map_track]['last_rules'] do
      if data.map_track[#data.map_track]['last_rules'][i] == track['last_tile'] then
        table.remove(data.map_track[#data.map_track]['last_rules'], i)
        break
      end
    end

    if #data.map_track[#data.map_track]['last_rules'] > 0 then
      local new_tile = data.map_track[#data.map_track]['last_rules'][math.random(1, #data.map_track[#data.map_track]['last_rules'])]
      local last_i = data.map_track[#data.map_track]['i']
      local last_j = data.map_track[#data.map_track]['j']

      --collapse manualy the contradiction tile
      data.map[last_i][last_j] = new_tile
      data.entropy_map[last_i][last_j] = {} 
      data.map_track[#data.map_track]['last_tile'] = new_tile
      data.map_track['last_tile'] = new_tile
      data.entropy_map = create_entropy_map(data)
      update_entropy_map(data)
      ok = true
    else
      --No rules left, try the tile before.
      table.remove(data.map_track)
      ok = backtrack(data)
    end
  else -- TRACK TABLE IS EMPTY
    ok = false
  end

  return ok

end

----- COLLAPSE --------------------------------------

local function choose_new_tile(data, best_tiles)
  --Maybe add some override over the purely random?
  local tile_pos = best_tiles[math.random(1, #best_tiles)]
  local rules = data.entropy_map[tile_pos[1]][tile_pos[2]]
  local new_tile = rules[math.random(1, #rules)]

  --Update map with the new tile
  data.map[tile_pos[1]][tile_pos[2]] = new_tile

  --Mark tile as collapsed
  data.entropy_map[tile_pos[1]][tile_pos[2]] = {}

  --Mark the trail
  local track = {
    i = tile_pos[1],
    j = tile_pos[2],
    last_tile = new_tile,
    last_rules = rules,
  }

  table.insert(data.map_track, track)

end


local function get_map_zeros(data)
  local count = 0

  for i=1, #data.map do
    for j=1, #data.map[i] do
      if data.map[i][j] == 0 then
        count = count + 1
      end
    end
  end

  return count 
end


local function collapse_map(data)
  local min_ent = data.n_tiles + 1
  local best_tiles = {}
  local b_tile = {}
  local ok = true
  
  -- Check if last iteration dont caused a contradiction
  if check_flaws(data) then
    ok = backtrack(data)
  else
    --collapse the map
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

  end

  --Return if the generation is done.
  if #best_tiles > 0 then
    choose_new_tile(data, best_tiles)
    if not ok then
      fail_count = fail_count + 1
      return true
    else
      return false
    end
  else
    if not ok then fail_count = fail_count + 1 end

    if is_map_ok(data) or not ok then
      return true 
    else
      return false 
    end
  end

end


----- W.F.C ------------------------------------------

function wfc(data)
  local generation_done = false

  while not generation_done do
    update_entropy_map(data)
    generation_done = collapse_map(data)
  end

end


-----  INIT  ----------------------------------------

function wfc_init(m_wid, m_len, num_tiles, t_size, t_sample, s_map)
  math.randomseed(os.time())
  --math.randomseed(666)

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
    map_track = {},
    problem_tile = {},
    backtrack_count = 0,
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

  return data

end


local function test()
  local tile_map_sample = {
    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
    {1,1,1,1,2,1,3,1,4,1,10,1,16,1,22,1,3,2,3,3,3,3},
    {1,7,8,9,1,1,1,1,1,1,1,1,1,1,1,1,2,5,2,3,5,3},
    {1,13,14,15,1,1,1,5,1,6,1,1,1,17,18,1,2,11,2,3,11,3},
    {1,13,14,15,1,1,1,11,1,12,1,1,1,23,24,1,2,2,2,3,3,3},
    {1,19,20,21,1,1,1,1,1,1,1,1,1,1,1,1,5,5,5,6,6,6},
    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,11,11,11,12,12,12},
    {1,1,1,1,1,1,1,1,1,1,1,1,1,4,5,4,6,4,6,16,6,16},
    {1,1,1,1,1,1,1,1,1,1,1,1,1,4,11,4,12,4,12,16,12,16},
  }

  local data = nil
  local start_time = 0
  local end_time = 0
  local total_time = 0
  local elapsed_time = 0

  local map_len = 128 
  local map_wid = 128
  local n_tiles = 24
  local tile_size = 32
  local map_size = map_len * map_wid

  local backtrack_count = 0

  local iterations = 10

  print('###  WFC  ###')
  print('\nMAP LEN: ' .. tostring(map_len))
  print('MAP WID: ' .. tostring(map_wid))
  print('TILESET SIZE: ' .. tostring(n_tiles))
  print('NUMBER OF TILES: ' .. tostring(map_size) .. '\n')
  
  for i=1, iterations do
    print('ITERATION: ' .. tostring(i))
    elapsed_time = 0
    start_time = os.clock()
    data = wfc_init(map_len, map_wid, n_tiles, tile_size, tile_map_sample, nil)
    wfc(data)
    end_time = os.clock()
    elapsed_time = end_time - start_time
    total_time = total_time + elapsed_time
    backtrack_count = backtrack_count + data.backtrack_count
    print('NUMBER OF TILES: ' .. tostring(map_size))
    print('BACKTRACK COUNT: ' .. tostring(data.backtrack_count))
    print('FAIL COUNT: ' .. tostring(fail_count))
    print('ELAPSED TIME: ' .. tostring(elapsed_time) .. 's\n')
  end

  print('\n###  REPORT ###')
  print('\nTOTAL TIME: ' .. tostring(total_time) .. 's')
  print('AVARAGE TIME: ' .. tostring(total_time / iterations) .. 's')
  print('AVARAGE BACKTRACKS: ' .. tostring(backtrack_count / iterations))
  print('FAIL COUNT: ' .. tostring(fail_count) .. '\n')

end

test()
