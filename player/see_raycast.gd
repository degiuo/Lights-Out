extends RayCast3D

@onready var label_interact: Label = $"../../../gui/Label"
@onready var player_node = get_node("../../..") 

func _physics_process(_delta: float) -> void:
	# Если нажали "drop" и в руках что-то есть — выбрасываем и выходим
	if Input.is_action_just_pressed("drop") and player_node.held_body != null:
		player_node.drop_object()
		return 
		
	if Input.is_action_just_pressed("throw") and player_node.held_body != null:
		player_node.throw_object()
		return

	if is_colliding():
		var target = get_collider()
		# Интерактивные объекты (полки, кассы)
		if target.has_method("interact"):
			label_interact.visible = true
			label_interact.text = "[E] Взаимодействовать"
			if Input.is_action_just_pressed("interact"):
				target.interact(player_node) 
				
		# Физические предметы (банки, стулья)
		elif target is RigidBody3D:
			label_interact.visible = true
			label_interact.text = "[E] Взять"
			if Input.is_action_just_pressed("interact") and player_node.held_body == null:
				player_node.grab_object(target)
				
		else:
			label_interact.visible = false
	else:
		label_interact.visible = false
