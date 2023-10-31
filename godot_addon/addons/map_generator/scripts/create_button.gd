@tool
extends Button

var lua: LuaAPI = LuaAPI.new()

func _enter_tree():
	print("Loaded Lua Plugin")
	lua.bind_libraries(["base", "table", "string"])
	pressed.connect(clicked)


func clicked():
	print("OLD SCRIPT")
	#lua.do_file("res://scripts/lua/wfc.lua")


	var matriz: Array = [
		[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
		[1,1,1,1,2,1,3,1,4,1,10,1,16,1,22,1,3,2,3,3,3,3],
		[1,7,8,9,1,1,1,1,1,1,1,1,1,1,1,1,2,5,2,3,5,3],
		[1,13,14,15,1,1,1,5,1,6,1,1,1,17,18,1,2,11,2,3,11,3],
		[1,13,14,15,1,1,1,11,1,12,1,1,1,23,24,1,2,2,2,3,3,3],
		[1,19,20,21,1,1,1,1,1,1,1,1,1,1,1,1,5,5,5,6,6,6],
		[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,11,11,11,12,12,12],
		[1,1,1,1,1,1,1,1,1,1,1,1,1,4,5,4,6,4,6,16,6,16],
		[1,1,1,1,1,1,1,1,1,1,1,1,1,4,11,4,12,4,12,16,12,16],
	]
	#var output = lua.call_function("godot_wfc", [matriz])
	#print(output)
