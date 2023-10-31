extends Node2D

var ca_checked = false
var sn_checked = false
var wfc_checked = false

var import_tilemap_size = 0
var import_tile_size = 0
var import_tilemap_path = ""

var map_size = 0
var matrix = null

var lua = LuaAPI.new()

@onready var c_tile_map = $"map_view/TileMap"

# Called when the node enters the scene tree for the first time.
func _ready():
	lua.bind_libraries(["base", "table", "string"])
	pass


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
		lua.do_file("WFC.lua")
		#matrix = lua.call_function("wfc", ["BATEU!!!",matriz])
		#c_tile_map.update_generate_new_map(matrix, map_wid, map_len, tilemap_wid, tilemap_len)
		pass
	else:
		print("OPCAO INVALIDA!!!!")
	#c_tile_map.create_tile_map()
	#print("sn checked: ", sn_checked)
	#print("ca checked: ", ca_checked)
	#print("wfc checked: ", wfc_checked)
	#print("-----  imports  -----")
	#print("import tilemap size: ", import_tilemap_size)
	#print("import tile size: ", import_tile_size)
	#print("import tilemap path: ", import_tilemap_path)
	#print("map size: ", map_size)


func _on_exit_button_pressed():
	get_tree().quit()
