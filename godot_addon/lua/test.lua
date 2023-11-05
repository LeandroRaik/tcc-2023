



local function read_file(path)
  local matrix = {}
  local file = io.open(path, "r")

  for line in file:lines() do
    if line:sub(1,1) ~= "#" then --allow comments
      local row = {}
      for val in line:gmatch("[^,]+") do --split by ','
        table.insert(row, tonumber(val))
      end
      table.insert(matrix, row)
    end
  end

  for i=1, #matrix do
    for v=1, #matrix[i] do
      io.write(matrix[i][v] .. ",")
    end
    print()
  end

  file:close()

  return matrix

end


read_file("sample_map.txt")

