---##  Wave Function Collapse  ##---

--[[

-Use the function wfc_init to create data structure
-Use the function wfc_step to run the next iteration of wfc


--]]

local sleep_time = 0.0
local RED = "\27[31m"
local GREEN = "\27[32m"
local YELLOW = "\27[33m"
local RESET_COLOR = "\27[0m"
local problem_tile = {}


----- PRINTING ------------------------------------

local function print_map(matrix, data)
  local pad = ''
  print('\n--------  MAP  --------\n')
  for i=1, #matrix do
    for j=1, #matrix[i] do
      if matrix[i][j] < 10 then
        pad = '0'
      else
        pad = ''
      end
      
      if data.map_track[#data.map_track]['i'] == i and data.map_track[#data.map_track]['j'] == j then
        io.write(YELLOW .. pad .. matrix[i][j] .. RESET_COLOR, ' ')
      else
        io.write(pad .. matrix[i][j], ' ')
      end

    end
    print()
  end
  print()
end


local function print_tile_count(data)
  print('----- SAMPLE TILE COUNT -----\n')
  for i=1, #data.tile_count do
    if i < 10 then
      print('0' .. tostring(i) .. ' => ' .. tostring(data.tile_count[i]))
    else
      print(tostring(i) .. ' => ' .. tostring(data.tile_count[i]))
    end
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
      for l=1, #vv do
        print(vv[l])
      end
    end
    print()
  end
end



local function print_entropy_map_old(data)
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

local function print_entropy_map(data)
  local pad = ''
  local p_i = 0
  local p_j = 0

  if #problem_tile > 0 then
    p_i = problem_tile[1]
    p_j = problem_tile[2]
  end

  print('----- ENTROPY MAP -----\n')
  for i=1, #data.entropy_map do
    for j=1, #data.entropy_map[i] do
      if #data.entropy_map[i][j] < 10 then
        pad = '0'
      else
        pad = ''
      end

      if data.map_track[#data.map_track]['i'] == i and data.map_track[#data.map_track]['j'] == j then
        io.write(YELLOW .. pad .. #data.entropy_map[i][j] .. RESET_COLOR, ' ')
      elseif i == p_i and j == p_j then
        io.write(RED .. pad .. #data.entropy_map[i][j] .. RESET_COLOR, ' ')
      else
        io.write(pad .. #data.entropy_map[i][j], ' ')
      end
    end
    print()
  end
end

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


local function reset_map_info(data)
end


local function check_flaws(data)
  local flaw = false

  for i=1, #data.map do
    for j=1, #data.map[i] do
      if data.map[i][j] == 0 and #data.entropy_map[i][j] == 0 then
        flaw = true
        problem_tile = {i, j}
        break
      end
    end
  end

  if not flaw then problem_tile = {} end

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
  local track = data.map_track[#data.map_track]
  print('## BACKTRACK ##')
  print('MAP TRACK:', #data.map_track)

  if #data.map_track == 0 then
    -- FAILED! RECREATE THE MAP AGAIN (FAILSAFE)
    print('ERROR: NO TRACK LEFT!')
    os.exit()
  end
  
  print('LAST TILE: ' .. tostring(track['last_tile']))
  print('I: ' .. tostring(track['i']))
  print('J: ' .. tostring(track['j']))

  print('RULES BEFORE:')
  for k,v in pairs(data.map_track[#data.map_track].last_rules) do
    print(k, v)
  end

  print('\nBEFORE BRACKTRACK:')
  print_map(data.map, data)
  print_entropy_map(data)

  --Removes last attempt from old rules
  for i=1, #data.map_track[#data.map_track]['last_rules'] do
    if data.map_track[#data.map_track]['last_rules'][i] == track['last_tile'] then
      table.remove(data.map_track[#data.map_track]['last_rules'], i)
      break
    end
  end


  print('\nRULES AFTER:')
  for k,v in pairs(data.map_track[#data.map_track].last_rules) do
    print(k, v)
  end

  print('PROBLEM TILE:\nI: ' .. tostring(problem_tile[1]) .. ' x J:' .. tostring(problem_tile[2]))

  --print(RED .. '\nBACKTRACK! PRESS ENTER TO CONTINUE..' .. RESET_COLOR)
  --io.read()

  
  if #data.map_track[#data.map_track]['last_rules'] > 0 then
    local new_tile = data.map_track[#data.map_track]['last_rules'][math.random(1, #data.map_track[#data.map_track]['last_rules'])]
    local last_i = data.map_track[#data.map_track]['i']
    local last_j = data.map_track[#data.map_track]['j']

    print('NEW TILE: ' .. tostring(new_tile))
    print('LAST I: ' .. tostring(last_i))
    print('LAST J: ' .. tostring(last_j))

    --local new_tile = track.last_rules[math.random(1, #track.last_rules)]

    --data.entropy_map = create_entropy_map(data)

    data.map[last_i][last_j] = new_tile
    data.entropy_map[last_i][last_j] = {} 
    data.map_track[#data.map_track]['last_tile'] = new_tile
    data.map_track['last_tile'] = new_tile
    data.entropy_map = create_entropy_map(data)
    update_entropy_map(data)
  else
    --No rules left, try the tile before.
    print('NO RULES LEFT! BACKTRACKING..')
    table.remove(data.map_track)
    backtrack(data)
  end


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
  
  -- Check if last iteration dont caused a contradiction
  if check_flaws(data) then
    backtrack(data)
  --end
  else--

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

  end--


  print('\nAFTER COLLAPSE:\n')
  print_map(data.map, data)
  print_entropy_map(data)

  print('\nzeros:  ' .. tostring(get_map_zeros(data)))

  if is_map_ok(data) then
    print('map ok: ' .. GREEN .. tostring(is_map_ok(data)) .. RESET_COLOR)
  else
    print('map ok: ' .. RED .. tostring(is_map_ok(data)) .. RESET_COLOR)
  end

  if not check_flaws(data) then
    print('flaws:  ' .. GREEN .. tostring(check_flaws(data)) .. RESET_COLOR)
  else
    print('flaws:  ' .. RED .. tostring(check_flaws(data)) .. RESET_COLOR)
  end

  if sleep_time > 0 then sleep(sleep_time) end

  --Return if the generation is done.
  if #best_tiles > 0 then
    choose_new_tile(data, best_tiles)
    return false 
  else
    if is_map_ok(data) then
      return true 
    else
      return false 
    end
  end

end




----- W.F.C ------------------------------------------

function wfc(data)
  local done = false
  local count = 1
  local atempts = 1


  local n_zeros = get_map_zeros(data) 

  --print_rules(data)
  --print_map(data.sample)
  --print_entropy_map(data)
  --print_map(data.map)

  while not done do
    print('\n#### LOOP COUNT: ' .. tostring(count) .. ' ####\n')
    n_zeros = get_map_zeros(data)

    update_entropy_map(data)
    --print_entropy_map(data)

    done = collapse_map(data)
    --print_map(data.map)
    count = count + 1

    if not is_map_ok(data) and done then
      print(RED .. 'FAILED!' .. RESET_COLOR)
    end
  end

  if is_map_ok(data) then print('\n' .. GREEN .. 'SUCCESS!' .. RESET_COLOR) end

  print_map(data.map, data)

  print("\nThat's all folks!\n")

end


function do_wfc_step(data, step, debug)
  print('STEP: ' .. tostring(step))
  --Create new entropy map
  update_entropy_map(data)

  if debug then print_entropy_map(data) end

  collapse_map(data)

  if debug then print_map(data.map, data) end


end


-----  INIT  ----------------------------------------

function wfc_init(m_wid, m_len, num_tiles, t_size, t_sample, s_map, debug)
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
    print_map(data.sample, data)
    print_rules(data)
    print_tile_count(data)
    print_entropy_map(data)
    print_map(data.map, data)
  end

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

  local data = wfc_init(64, 64, 24, 32, tile_map_sample, nil, true)
  wfc(data)
end


test()

