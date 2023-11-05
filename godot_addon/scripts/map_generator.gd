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

@onready var c_tile_map = $"map_view/TileMap"

# Called when the node enters the scene tree for the first time.
func _ready():
	lua.bind_libraries(["base", "table", "string", "io", "os", "debug", "math"])


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


func handle_wfc():
	print("CREATING MAP..")
	lua.do_file("res://lua/wfc.lua")
	var map_len = 16
	var map_wid = 16
	var n_tiles = 24
	var tile_size = 32
	var tilemap_wid = 6
	var tilemap_len = 4
	var file_path = "sample_map.txt"
	var wfc = lua.call_function("godot_wfc", [file_path, map_len, map_wid, n_tiles, tile_size])
	
	if wfc is LuaError:
		print(wfc.message)
	else:
		print(wfc)
		c_tile_map.generate_new_map(wfc, map_wid, map_len, tilemap_wid, tilemap_len)
		#c_tile_map.generate_new_map(wfc, 16, 16, 2, 2)
		#c_tile_map.generate_new_map()

# BUTTONS
func _on_create_button_pressed():
	if wfc_checked:
		handle_wfc()
	else:
		print("OPCAO INVALIDA!!!!")


func _on_exit_button_pressed():
	get_tree().quit()
