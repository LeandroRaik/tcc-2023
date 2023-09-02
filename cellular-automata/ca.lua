-- CELLULAR AUTOMATA --

local function print_map(tile_map, map_x, map_y)
  for i=1, map_x do
    for j=1, map_y do
      if tile_map[i][j] == 1 then
        io.write('x ')
      else
        io.write('  ')
      end
    end
    print()
  end
end


local function init(map_x, map_y)
  local tile_map = {}
  for i=1, map_x do
    tile_map[i] = {}
    for j=1, map_y do
      tile_map[i][j] = math.random(0,1)
    end
  end
  return tile_map
end


local function get_neighbors(x, y, tile_map, map_x, map_y)  
  local sum = 0
  for i=x-1, x+1 do
    for j=y-1, y+1 do
      if (i >= 1 and i < map_x) and (j >= 1 and j < map_y) and (i ~= x or j ~= y) then
        sum = sum + tile_map[i][j]
      end
    end
  end
  return sum
end


local function cellular_automata(tile_map, size_x, size_y)
  local new_tile_map = init(size_x, size_y)
  for i=1, size_x do
    for j=1, size_y do
      local sum = get_neighbors(i, j, tile_map, size_x, size_y)

      --Apply the rule
      if sum > 3 then
        new_tile_map[i][j] = 1
      else
        new_tile_map[i][j] = 0
      end
    end
  end
  return new_tile_map
end


function create_map()
  local seed = math.randomseed(os.time())
  local size_x = 32 
  local size_y = 32 
  local tile_map = init(size_x, size_y)
  local iterations = 10
  for i=1, iterations do
    tile_map = cellular_automata(tile_map, size_x, size_y)
  end
  print_map(tile_map, size_x, size_y)
end

create_map() 
