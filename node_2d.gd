extends Control

var dragged_die
var dragged_die_position
var dragged_die_z_index
var dragged_die_cell_index
var position_dif
var closest_die
var score
var field_size
var row_size

#TODO action lock while dice animated
#TODO fix bug: trigger stacking without moving if match to the right
#TODO finish animation before end-game screen
#TODO tutorial (gif with dragging process?)
#TODO code cleanup
#TODO "lifes" and achivement. Skins?

#Idea: show possible moves while dragging die

func end_game_check() -> bool:
	for i in range(field_size):
		for j in [i-row_size, i-1, i+1, i+row_size]:
			if j >= 0 and j < field_size:
				if abs(j - i) == row_size or (abs(j - i) == 1 and (i)/row_size == (j)/row_size):
					#print(str(i) + ' - ' + str(j))
					var i_value
					for c in get_node("GridContainer").get_node("Panel" + str(i+1)).get_children():
						if c.name.begins_with("Sprite2D"):
							i_value = c.value
					var j_value
					for c in get_node("GridContainer").get_node("Panel" + str(j+1)).get_children():
						if c.name.begins_with("Sprite2D"):
							j_value = c.value
					if i_value and j_value and i_value == j_value:
						return false
	return true

func get_die(i) -> void:
	var die_value = randi_range(1,6)
	var die_raw = load("sprite_2d.tscn")
	var die = die_raw.instantiate()
	die.set_value(die_value)
	die.get_node("AnimationPlayer").play("roll")
	get_node("GridContainer").get_node("Panel" + str(i)).add_child(die)
	die.position = Vector2(42, 42)

func new_game() -> void:
	score = 0
	get_node("score").text = str(score)
	while end_game_check():
		for i in range(field_size):
			for c in get_node("GridContainer").get_node("Panel" + str(i+1)).get_children():
				if c.name.begins_with("Sprite2D"):
					c.set_value(randi_range(1,6))
					c.get_node("AnimationPlayer").play("roll")

func _on_ready() -> void:
	field_size = get_node("GridContainer").columns * get_node("GridContainer").columns
	row_size = get_node("GridContainer").columns
	var rnd = RandomNumberGenerator.new()
	for i in range(field_size):
		get_die(i+1)
	new_game()

func _input( event ):
	if event is InputEventMouseButton and event.button_index == 1:
		var space_state = get_world_2d().direct_space_state
		if event.pressed:
			var mouse_pos = get_global_mouse_position()
			var query = PhysicsPointQueryParameters2D.new()
			query.position = mouse_pos
			query.collide_with_areas = true
			#query.collision_mask = 1
			var result = space_state.intersect_point(query)
			if result.size() > 0:
				for r in result:
					if r.collider.get_parent().name.begins_with("Sprite2D"):
						dragged_die = r.collider.get_parent()
						dragged_die_position = dragged_die.position
						position_dif = (dragged_die.position - mouse_pos)
						dragged_die_cell_index = int(dragged_die.get_parent().name.substr(5, -1))
						dragged_die_z_index = dragged_die.z_index
						dragged_die.z_index += 1
		else:
			if dragged_die:
				var min_dist
				for a in dragged_die.get_node("Area2D").get_overlapping_areas():
					if a.get_parent().name.begins_with("Sprite2D"):
						var dist = a.get_parent().position.distance_to(dragged_die.position)# + (dragged_die.size / 4))
						if min_dist:
							if dist < min_dist:
								min_dist = dist
								closest_die = a.get_parent()
						else:
							min_dist = dist
							closest_die = a.get_parent()
				if closest_die:
					var closest_die_index = int(closest_die.get_parent().name.substr(5, -1))
					if abs(dragged_die_cell_index - closest_die_index) == row_size or (abs(dragged_die_cell_index - closest_die_index) == 1 and (dragged_die_cell_index-1)/row_size == (closest_die_index-1)/row_size):
						if closest_die.value == dragged_die.value:
							closest_die.get_node("AnimationPlayer").play("value_slide")
							score += dragged_die.value
							get_node("score").text = str(score)
							closest_die.set_value(closest_die.value % 6 + 1)
							dragged_die.reparent(self)
							dragged_die.queue_free()
							get_die(dragged_die_cell_index)
							if end_game_check():
								get_node("end_game").visible = true
								get_node("end_game").get_node("Label3").text = str(score)
				dragged_die.position = dragged_die_position
				dragged_die.z_index = dragged_die_z_index
				dragged_die_position = null
				dragged_die = null
						
func _process( delta ):
	if dragged_die:
		var mouse_pos = get_global_mouse_position()
		dragged_die.position = mouse_pos + position_dif


func _on_button_button_up() -> void:
	get_node("end_game").visible = false
	new_game()


func _on_tutorial_button_button_up() -> void:
	get_node("tutorial").visible = false
