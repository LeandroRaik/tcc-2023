@tool
extends Button

var lua: LuaAPI = LuaAPI.new()


func _enter_tree():
	print("Loaded Lua Plugin")
	lua.bind_libraries(["base", "table", "string"])
	pressed.connect(clicked)


func clicked():
	print("Creating map")
	lua.do_file("res://scripts/TESTE.lua")
	var matriz: Array = [
		[1,2,3],
		[4,5,6],
		[7,8,9]
	]
	var output = lua.call_function("wfc", ["BATEU!!!",matriz])
	print(output)
