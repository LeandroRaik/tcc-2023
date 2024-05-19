-- Seed the random number generator
math.randomseed(os.time())

-- Gradient table for 2D Simplex Noise
grad3 = {
    {-1, 1, 0}, {1, 1, 0}, {-1, -1, 0}, {1, -1, 0},
    {0, 1, 1}, {0, 1, -1}, {0, -1, 1}, {0, -1, -1},
    {1, 0, 1}, {1, 0, -1}, {-1, 0, 1}, {-1, 0, -1},
    {1, 1, 0}, {-1, 1, 0}, {0, 1, 1}, {0, 1, -1},
    {1, 0, 1}, {-1, 0, 1}, {0, -1, 1}, {0, -1, -1},
    {1, -1, 1}, {-1, 1, -1}, {1, 1, 1}, {-1, -1, -1},
    {2, 1, 0}, {2, -1, 0}, {-2, 1, 0}, {-2, -1, 0},
    {0, 2, 1}, {0, 2, -1}, {0, -2, 1}, {0, -2, -1},
    {1, 0, 2}, {1, 0, -2}, {-1, 0, 2}, {-1, 0, -2},
    {1, 2, 0}, {-1, 2, 0}, {1, -2, 0}, {-1, -2, 0},
    {2, 0, 1}, {2, 0, -1}, {-2, 0, 1}, {-2, 0, -1},
    {1, 1, 2}, {1, -1, 2}, {-1, 1, 2}, {-1, -1, 2},
    {1, 1, -2}, {1, -1, -2}, {-1, 1, -2}, {-1, -1, -2},
    {2, 1, 1}, {2, 1, -1}, {2, -1, 1}, {2, -1, -1},
    {-2, 1, 1}, {-2, 1, -1}, {-2, -1, 1}, {-2, -1, -1},
    {1, 2, 1}, {1, 2, -1}, {1, -2, 1}, {1, -2, -1},
    {-1, 2, 1}, {-1, 2, -1}, {-1, -2, 1}, {-1, -2, -1},
    {3, 1, 0}, {3, -1, 0}, {-3, 1, 0}, {-3, -1, 0},
    {0, 3, 1}, {0, 3, -1}, {0, -3, 1}, {0, -3, -1},
    {1, 0, 3}, {1, 0, -3}, {-1, 0, 3}, {-1, 0, -3},
    {1, 3, 0}, {-1, 3, 0}, {1, -3, 0}, {-1, -3, 0},
    {3, 0, 1}, {3, 0, -1}, {-3, 0, 1}, {-3, 0, -1},
    {1, 1, 3}, {1, -1, 3}, {-1, 1, 3}, {-1, -1, 3},
    {1, 1, -3}, {1, -1, -3}, {-1, 1, -3}, {-1, -1, -3},
    {3, 1, 1}, {3, 1, -1}, {3, -1, 1}, {3, -1, -1},
    {-3, 1, 1}, {-3, 1, -1}, {-3, -1, 1}, {-3, -1, -1},
    {1, 3, 1}, {1, 3, -1}, {1, -3, 1}, {1, -3, -1},
    {-1, 3, 1}, {-1, 3, -1}, {-1, -3, 1}, {-1, -3, -1},
    {2, 2, 1}, {2, 2, -1}, {2, -2, 1}, {2, -2, -1},
    {-2, 2, 1}, {-2, 2, -1}, {-2, -2, 1}, {-2, -2, -1},
    {2, 1, 2}, {2, -1, 2}, {-2, 1, 2}, {-2, -1, 2},
    {2, 1, -2}, {2, -1, -2}, {-2, 1, -2}, {-2, -1, -2},
    {1, 2, 2}, {1, 2, -2}, {1, -2, 2}, {1, -2, -2},
    {-1, 2, 2}, {-1, 2, -2}, {-1, -2, 2}, {-1, -2, -2},
    {3, 2, 0}, {3, -2, 0}, {-3, 2, 0}, {-3, -2, 0},
    {0, 3, 2}, {0, 3, -2}, {0, -3, 2}, {0, -3, -2},
    {2, 0, 3}, {2, 0, -3}, {-2, 0, 3}, {-2, 0, -3},
    {2, 3, 0}, {-2, 3, 0}, {2, -3, 0}, {-2, -3, 0},
    {3, 0, 2}, {3, 0, -2}, {-3, 0, 2}, {-3, 0, -2},
    {2, 2, 3}, {2, -2, 3}, {-2, 2, 3}, {-2, -2, 3}
}

-- Permutation table
local p = {}
for i = 1, 512 do
    p[i] = math.random(0, 255)
end

-- Dot product function
function dot(g, x, y)
    return g[1] * x + g[2] * y
end

-- 2D Simplex Noise function
function noise(xin, yin)
    local F2 = 0.5 * (math.sqrt(3.0) - 1.0)
    local G2 = (3.0 - math.sqrt(3.0)) / 6.0
    local s = (xin + yin) * F2
    local i = math.floor(xin + s)
    local j = math.floor(yin + s)
    local t = (i + j) * G2
    local X0 = i - t
    local Y0 = j - t
    local x0 = xin - X0
    local y0 = yin - Y0
    
    -- Determine which simplex cell we're in
    local i1, j1 = 0, 0
    if x0 > y0 then
        i1, j1 = 1, 0
    else
        i1, j1 = 0, 1
    end
    
    -- Offsets for the second (middle) corner of the simplex
    local x1 = x0 - i1 + G2
    local y1 = y0 - j1 + G2
    -- Offsets for the third (last) corner of the simplex
    local x2 = x0 - 1.0 + 2.0 * G2
    local y2 = y0 - 1.0 + 2.0 * G2
    
    -- Calculate the hashed gradient indices of the three simplex corners
    local ii = i % 256 + 1
    local jj = j % 256 + 1
    local gi0 = p[ii + p[jj]] % #grad3 + 1
    local gi1 = p[ii + i1 + p[jj + j1]] % #grad3 + 1
    local gi2 = p[ii + 1 + p[jj + 1]] % #grad3 + 1
    
    -- Calculate the contribution from the three corners
    local function contribution(t, x, y, gi)
        if t < 0 then return 0 end
        t = t * t
        return t * t * dot(grad3[gi], x, y)
    end
    
    local n0 = contribution(0.5 - x0 * x0 - y0 * y0, x0, y0, gi0)
    local n1 = contribution(0.5 - x1 * x1 - y1 * y1, x1, y1, gi1)
    local n2 = contribution(0.5 - x2 * x2 - y2 * y2, x2, y2, gi2)
    
    -- Add contributions from each corner to get the final noise value
    return 40 * (n0 + n1 + n2)
end

