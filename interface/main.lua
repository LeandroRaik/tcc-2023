--  WFC STEP - LOVE PROJECT --

-- Import WFC functions.
dofile('simplex-lua/simplex.lua')

-- LOVE ------------------------------------------------------------------

local width = 520
local height = 520
local frequency = 20
local tile_size = 2
local noiseMap = {}
local colors = {
  {-1.0, {255, 255, 255, 255}},   -- White snowy peaks (inverted from 1)
  {-0.9, {220, 220, 220, 255}},    -- Light grey for rocky terrain (inverted from -0.7)
  {-0.5, {139, 69, 19, 255}},      -- Brown mountains (inverted from -0.5)
  {-0.2, {34, 139, 34, 255}},    -- Darker green for forests (inverted from 0.3)
  {-0.1, {154, 205, 50, 255}},     -- Light green for plains (inverted from 0.1)
  {-0.55, {255, 222, 173, 255}},      -- Peachy sand color (inverted from -0.2)
  {0.0, {255, 255, 153, 255}},       -- Pale yellow for beaches (inverted from 0)
  {0.4, {30, 144, 255, 255}},      -- Sky blue (inverted from 0.5)
  {0.6, {0, 191, 255, 255}},       -- Cyan for shallow water (inverted from 0.6)
  {0.7, {65, 105, 225, 255}},      -- Royal blue for deeper water (inverted from 0.7)
  {1.0, {0, 0, 128, 255}}          -- Deep blue ocean (inverted from -1, repeated for completeness)
}
function fractalNoise(x, y, octaves, persistence, lacunarity)
  local total = 0
  local frequency = 2
  local amplitude = 1
  local maxAmplitude = 0
  for i = 1, octaves do
      total = total + noise(x * frequency, y * frequency) * amplitude
      maxAmplitude = maxAmplitude + amplitude
      amplitude = amplitude * persistence
      frequency = frequency * lacunarity
  end

  return total / maxAmplitude
end


-- Generate noise map
function genNoise()
    for x = 1, width do
        noiseMap[x] = {}
        for y = 1, height do
            local xin = x / width 
            local yin = y / height 
            local continentNoise = fractalNoise(xin, yin, 10, 0.5 , 2)
            noiseMap[x][y] = continentNoise
        end
    end
end


local function normalizeNoiseMap(noiseMap, width, height)
  local minVal, maxVal = math.huge, -math.huge
  for x = 1, width do
      for y = 1, height do
          minVal = math.min(minVal, noiseMap[x][y])
          maxVal = math.max(maxVal, noiseMap[x][y])
      end
  end
  local range = maxVal - minVal
  for x = 1, width do
      for y = 1, height do
          noiseMap[x][y] = 2 * ((noiseMap[x][y] - minVal) / range) - 1
      end
  end
end


local function lerp(a, b, t)
  return a + (b - a) * t
end

-- Interpolate between two colors
local function interpolateColor(color1, color2, t)
  local r = lerp(color1[1], color2[1], t)
  local g = lerp(color1[2], color2[2], t)
  local b = lerp(color1[3], color2[3], t)
  local a = lerp(color1[4] or 255, color2[4] or 255, t)
  return {r, g, b, a}
end

-- Find the colors to interpolate between based on the value
local function getColorForValue(value)
  for i = 1, #colors - 1 do
      local color1 = colors[i]
      local color2 = colors[i + 1]
      if value >= color1[1] and value <= color2[1] then
          local t = (value - color1[1]) / (color2[1] - color1[1])
          return interpolateColor(color1[2], color2[2], t)
      end
  end
  return colors[#colors][2]  -- Fallback to the last color if out of range
end

local function printColor(value, color)
  print(string.format("Value: %.2f -> R: %.2f, G: %.2f, B: %.2f, A: %.2f", value, color[1], color[2], color[3], color[4]))
end

-- First thing to be run
function love.load()
    print('\n\n###### CELLULAR AUTOMATA - DEMO ######')
    genNoise()
    love.window.setMode(width * tile_size, height * tile_size)
end

-- Input Keys
function love.keypressed(key)
    if key == "escape" then
        print("SEE YA")
        love.event.quit()
    elseif key == "space" then
        genNoise()
        if frequency > 0 then
            frequency = frequency - 2
        end
    end
end

-- Draw screen
function love.draw()
    normalizeNoiseMap(noiseMap, width, height)
    love.graphics.scale(1)

    for x = 1, width do
        for y = 1, height do
            --print(string.format("%.2f",noiseMap[x][y]))
            --local interpolatedColor = getColorForValue(tonumber(string.format("%.2f",noiseMap[x][y])))
            local interpolatedColor = getColorForValue(noiseMap[x][y])
            love.graphics.setColor(interpolatedColor[1] / 255, interpolatedColor[2] / 255, interpolatedColor[3] / 255, interpolatedColor[4] / 255)
            love.graphics.rectangle("fill", (x - 1) * tile_size, (y - 1) * tile_size, tile_size, tile_size)
        end
    end
end