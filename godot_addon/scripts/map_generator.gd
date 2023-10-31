extends Node2D

var ca_checked = false
var sn_checked = false
var wfc_checked = false

var import_tilemap_size = 0
var import_tile_size = 0
var import_tilemap_path = ""

var map_size = 0
var matrix = null

var lua: LuaAPI = LuaAPI.new()


var tile_map_sample: Array = [
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

@onready var c_tile_map = $"map_view/TileMap"

# Called when the node enters the scene tree for the first time.
func _ready():
	lua.bind_libraries(["base", "table", "string"])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# TEXT INPUTS
func _on_import_tile_path_ed_focus_exited():
	import_tilemap_path = $"input_menu/VBox/import_tile_path_ed".text

func _on_import_tile_map_size_ed_focus_exited():
	import_tilemap_size = int($"input_menu/VBox/import_tile_map_size_ed".text)

func _on_import_tile_size_ed_focus_exited():
	import_tile_size = int($"input_menu/VBox/import_tile_size_ed".text)

func _on_tile_map_size_focus_exited():
	map_size = int($"input_menu/VBox/tile_map_size".text)


# CHECK BOX
func _on_ca_box_toggled(toggled_on):
	if toggled_on == true:
		ca_checked = true
	else:
		ca_checked = false


func _on_sn_box_toggled(toggled_on):
	if toggled_on == true:
		sn_checked = true
	else:
		sn_checked = false


func _on_wfc_box_toggled(toggled_on):
	if toggled_on == true:
		wfc_checked = true
	else:
		wfc_checked = false


# BUTTONS
func _on_create_button_pressed():
	if wfc_checked:
		print("CREATING MAP..")
		lua.do_file("res://lua/wfc.lua")
		var map_len = 32
		var map_wid = 32
		var n_tiles = 24
		var tile_size = 32
		
		var volta_lua = lua.call_function("godot_wfc", [tile_map_sample, map_len, map_wid, n_tiles, tile_size])
		print(volta_lua)
		#for i in volta_lua.size():
			#for j in volta_lua[i].size():
				#print(volta_lua[i][j])
			#print()
		print("TERMINOU")
		#c_tile_map.update_generate_new_map(matrix, map_wid, map_len, tilemap_wid, tilemap_len)
	else:
		print("OPCAO INVALIDA!!!!")


func _on_exit_button_pressed():
	get_tree().quit()
