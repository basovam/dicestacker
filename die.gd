extends Sprite2D

var value

func set_value(input_value) -> void:
	var player = get_node("AnimationPlayer")
	var default_library: AnimationLibrary = player.get_animation_library("")
	var library_copy = default_library.duplicate()
	var player_copy = player.duplicate()
	var animation_orig: Animation = player_copy.get_animation("roll")
	var animation_copy = animation_orig.duplicate()
	var v = randi_range(1,6)
	for i in range(10):
		var new_v = randi_range(1,6)
		while new_v == v:
			new_v = randi_range(1,6)
		v = new_v
		var x = (v - 1) % 3
		var y = (v - 1) / 3
		var atlas_texture = AtlasTexture.new()
		atlas_texture.atlas = load("res://dice_simple.png")
		atlas_texture.region = Rect2(200 * x, 200 * y, 200, 200)
		animation_copy.track_set_key_value(0, i, atlas_texture)
	var x = (input_value - 1) % 3
	var y = (input_value - 1) / 3
	var atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = load("res://dice_simple.png")
	atlas_texture.region = Rect2(200 * x, 200 * y, 200, 200)
	animation_copy.track_set_key_value(0, 10, atlas_texture)
	self.texture = atlas_texture
	self.value = input_value
	if input_value == 1:
		get_node("value").text = "+" + str(6)
	else:
		get_node("value").text = "+" + str(input_value - 1)
	
	library_copy.add_animation("roll", animation_copy)
	player.rename_animation_library("", "default")
	player.add_animation_library("", library_copy)
