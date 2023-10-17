function wfc(text, m)
	local matrix ={
		{1,2},
		{1,2}
	} 
	print(text)
	for i = 1 , #m do
	   for j = 1 , #m[i] do
			print(m[i][j])
	   end
	   print()
	end 

	return matrix
end
