
math.randomseed(os.time())
local grad3 = {
    {1, 1, 0}, {-1, 1, 0}, {1, -1, 0}, {-1, -1, 0},
    {1, 0, 1}, {-1, 0, 1}, {1, 0, -1}, {-1, 0, -1},
    {0, 1, 1}, {0, -1, 1}, {0, 1, -1}, {0, -1, -1}
}

local p = {}
for i = 1, 512 do
    p[i] = math.random(0, 255)
end

local function dot(g, x, y)
    return g[1] * x + g[2] * y
end

local function noise(xin, yin)
    local F2 = 0.5 * (math.sqrt(3.0) - 1.0)
    local s = (xin + yin) * F2
    local i = math.floor(xin + s)
    local j = math.floor(yin + s)
    local G2 = (3.0 - math.sqrt(3.0)) / 6.0
    local t = (i + j) * G2
    local X0 = i - t
    local Y0 = j - t
    local x0 = xin - X0
    local y0 = yin - Y0
    local i1, j1
    if x0 > y0 then
        i1 = 1
        j1 = 0
    else
        i1 = 0
        j1 = 1
    end
    local x1 = x0 - i1 + G2
    local y1 = y0 - j1 + G2
    local x2 = x0 - 1.0 + 2.0 * G2
    local y2 = y0 - 1.0 + 2.0 * G2
    local ii = i % 12 + 1
    local jj = j % 12 + 1
    local gi0 = p[ii + p[jj]]
    local gi1 = p[ii + i1 + p[jj + j1]]
    local gi2 = p[ii + 1 + p[jj + 1]]
    local t0 = 0.5 - x0 * x0 - y0 * y0
    if t0 < 0 then
        n0 = 0
    else
        t0 = t0 * t0
        n0 = t0 * t0 * dot(grad3[gi0 % 12 + 1], x0, y0)
    end
    local t1 = 0.5 - x1 * x1 - y1 * y1
    if t1 < 0 then
        n1 = 0
    else
        t1 = t1 * t1
        n1 = t1 * t1 * dot(grad3[gi1 % 12 + 1], x1, y1)
    end
    local t2 = 0.5 - x2 * x2 - y2 * y2
    if t2 < 0 then
        n2 = 0
    else
        t2 = t2 * t2
        n2 = t2 * t2 * dot(grad3[gi2 % 12 + 1], x2, y2)
    end
    return 70.0 * (n0 + n1 + n2)
end

local width = 512
local height = 512
local octaves = 4
local noiseMap = {}

for x = 1, width do
    noiseMap[x] = {}
    for y = 1, height do
        local xin = x / width * 4 -- Increase the frequency to create more variation
        local yin = y / height * 4
        local continentNoise = noise(xin, yin)
        
        -- Adjust threshold values to control landmass generation
        local threshold = 0.0
        if continentNoise > threshold then
            noiseMap[x][y] = continentNoise -- Land
        else
            noiseMap[x][y] = 0.0 -- Ocean
        end
    end
end

local maxPixelValue = 255

local function writePGM(filename, data, width, height, maxPixelValue)
    local file = assert(io.open(filename, "wb"))
    file:write(string.format("P5\n%d %d\n%d\n", width, height, maxPixelValue))
    for y = 1, height do
        for x = 1, width do
            local value = math.floor(data[x][y] * maxPixelValue + 0.5)
            file:write(string.char(value))
        end
    end
    file:close()
end

writePGM("output.pgm", noiseMap, width, height, maxPixelValue)



