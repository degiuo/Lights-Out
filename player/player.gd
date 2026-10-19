extends CharacterBody3D

#node
@onready var head = $head
@onready var state_collision = $StateCollision
@onready var crouch_collision = $CrouchCollision
@onready var crouch_raycast = $crouch_raycast
@onready var pickup_point: Node3D = $"head/Camera3D/pickup_point"
@onready var camera: Camera3D = $"head/Camera3D"
#speed
var current_speed = 5.0

const walking_speed = 5.0

var sprint_time = 100.0
const sprint_speed = 9.0
const crouch_speed = 2.5

var lerp_speed = 10.0
var crouch_depth = -0.5

#hand
var held_item_scene: PackedScene = null
var held_item_node: Node3D = null

var held_body: RigidBody3D = null
var throw_force: float = 15.0 
var drop_distance: float = 1.0

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("crouch"):
		current_speed = crouch_speed
		head.position.y = lerp(head.position.y, 0.67 + crouch_depth, delta * lerp_speed)
		state_collision.disabled = true
		crouch_collision.disabled = false
	elif not crouch_raycast.is_colliding():
		head.position.y = lerp(head.position.y, 0.67, delta * lerp_speed)
		state_collision.disabled = false
		crouch_collision.disabled = true
		if Input.is_action_pressed("sprint") and sprint_time > 0:
			sprint_time -= delta * sprint_speed
			current_speed = sprint_speed
		else:
			current_speed = walking_speed
			if sprint_time < 100:
				sprint_time += delta * sprint_speed
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()

func pick_up(item_scene: PackedScene) -> bool:
	if held_item_node != null:
		print("Руки заняты!")
		return false
		
	held_item_scene = item_scene
	held_item_node = item_scene.instantiate()
	pickup_point.add_child(held_item_node)
	print("Взял предмет в руки.")
	return true

func clear_hands():
	if held_item_node:
		held_item_node.queue_free()
	held_item_scene = null
	held_item_node = null
	print("Убрал в рюкзак")


func grab_object(body: RigidBody3D) -> void:
	if held_body != null:
		return
		
	held_body = body
	held_body.freeze = true
	held_body.collision_layer = 0 
	held_body.collision_mask = 0
	
	held_body.reparent(pickup_point)
	held_body.position = Vector3.ZERO
	held_body.rotation = Vector3.ZERO 

# --- БРОСИТЬ (с силой) ---
func throw_object() -> void:
	if held_body == null:
		return
		
	var body_to_throw = held_body
	held_body = null
	
	# 1. Отцепляем от руки и возвращаем в мир
	body_to_throw.reparent(get_tree().current_scene)
	
	# 2. Включаем физику обратно
	_unfreeze_body(body_to_throw)
	
	# 3. Даем импульс (толчок) вперед от камеры
	var throw_dir = -camera.global_transform.basis.z
	body_to_throw.apply_central_impulse(throw_dir * throw_force)

# --- ВЫБРОСИТЬ/ПОЛОЖИТЬ (тихо) ---
func drop_object() -> void:
	if held_body == null:
		return
		
	var body_to_drop = held_body
	held_body = null
	
	# Сначала отцепляем от руки, чтобы найти правильную позицию в мире
	body_to_drop.reparent(get_tree().current_scene)
	
	# Ставим предмет чуть впереди игрока на пол
	var drop_pos = camera.global_position + (-camera.global_transform.basis.z * drop_distance)
	drop_pos.y = global_position.y + 0.2 # Чуть выше пола (подстрой под свой рост)
	body_to_drop.global_position = drop_pos
	
	_unfreeze_body(body_to_drop)

# --- Вспомогательная функция (чтобы не дублировать код) ---
func _unfreeze_body(body: RigidBody3D) -> void:
	body.freeze = false
	body.collision_layer = 1 # Убедись, что 1 - это слой физических объектов
	body.collision_mask = 1
