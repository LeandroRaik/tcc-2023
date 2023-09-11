-- LOVE PROJECT --

dofile('wfc/wfc.lua')

-- Define the dimensions of the tileset
local tileWidth = 32
local tileHeight = 32
local tilesetColumns = 6
local tilesetRows = 4

-- Define the scaling factor
local scale = 1

-- Load the tileset image
local tilesetImage

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

local data = wfc_init(10, 10, 24, 32, tile_map_sample, nil, true)

wfc(data)

--Used to draw the actual map
local customMap = data.map 

function love.load()
    -- Load the tileset image
    tilesetImage = love.graphics.newImage("sprites/tileset.png")

    -- Initialize quads
    for y = 0, tilesetRows - 1 do
        for x = 0, tilesetColumns - 1 do
            local quad = love.graphics.newQuad(
                x * tileWidth, y * tileHeight,
                tileWidth, tileHeight,
                tilesetImage:getWidth(), tilesetImage:getHeight()
            )
            table.insert(quads, quad)
        end
    end

    -- Set the screen size to match the scaled tilemap size
    love.window.setMode(#customMap[1] * tileWidth * scale, #customMap * tileHeight * scale)
end

function love.update(dt)
    -- Your update logic goes here
end

function love.draw()
    love.graphics.scale(scale) -- Scale the drawing

    for y = 1, #customMap do
        for x = 1, #customMap[1] do
            local tileIndex = customMap[y][x]
            local quad = quads[tileIndex]
            love.graphics.draw(tilesetImage, quad, (x - 1) * tileWidth, (y - 1) * tileHeight)
        end
    end
end

