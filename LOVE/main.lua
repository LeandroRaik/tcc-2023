-- LOVE PROJECT --

dofile('wfc/wfc.lua')

-- Define the dimensions of the tileset
local tile_width = 32
local tile_height = 32
local tile_set_columns = 6
local tile_set_rows = 4
local map_wid = 64 
local map_len = 64

-- Define the scaling factor
local scale = 1

-- Load the tileset image
local tile_set_image

-- Create a Quad for each tile in the tileset
local quads = {}


--Sample input
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


--wfc_init(m_wid, m_len, num_tiles, t_size, t_sample, s_map, debug)

local data = wfc_init(map_len, map_wid, 24, 32, tile_map_sample, nil, true)

wfc(data)

--Used to draw the actual map
local custom_map = data.map 

local function create_new_map(data)
  print('Creating new map..')
  data = wfc_init(map_len, map_wid, 24, 32, tile_map_sample, nil, true)
  wfc(data)
  custom_map = data.map
end


function love.load()
  -- Load the tileset image
  tile_set_image = love.graphics.newImage("sprites/tileset.png")

  -- Initialize quads
  for y = 0, tile_set_rows - 1 do
    for x = 0, tile_set_columns - 1 do
      local quad = love.graphics.newQuad(
        x * tile_width, y * tile_height,
        tile_width, tile_height,
        tile_set_image:getWidth(), tile_set_image:getHeight()
      )
      table.insert(quads, quad)
    end
  end

  -- Set the screen size to match the scaled tilemap size
  love.window.setMode(#custom_map[1] * tile_width * scale, #custom_map * tile_height * scale)
end


function love.update(dt)
  --main loop logic
end


function love.keypressed(key)
  if key == "space" then
    create_new_map(data)
  elseif key == "escape" then
    print("SEE YA")
    os.exit()
  end
end


function love.draw()
  love.graphics.scale(scale) -- Scale the drawing

  for y = 1, #custom_map do
    for x = 1, #custom_map[1] do
      local tile_index = custom_map[y][x]
      local quad = quads[tile_index]
      love.graphics.draw(tile_set_image, quad, (x - 1) * tile_width, (y - 1) * tile_height)
    end
  end
end

