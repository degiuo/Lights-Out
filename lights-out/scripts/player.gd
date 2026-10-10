extends CharacterBody3D

@onready var head = $head
@onready var state_collision = $StateCollision
@onready var crouch_collision = $CrouchCollision

var current_speed = 5.0

const walking_speed = 5.0
const sprint_speed = 8.0
const crouch_speed = 3.0

const mouse_sens = 0.25

var lerp_speed = 10.0
var crouch_depth = -0.5

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta: float) -> void:
	
	if Input.is_action_pressed("crouch"):
		current_speed = crouch_speed
		head.position.y = lerp(head.position.y, 0.67 + crouch_depth, delta * lerp_speed)
		state_collision.disabled = true
		crouch_collision.disabled = false
	else:
		head.position.y = lerp(head.position.y, 0.67, delta * lerp_speed)
		state_collision.disabled = false
		crouch_collision.disabled = true
		if Input.is_action_pressed("sprint"):
			current_speed = sprint_speed
		else:
			current_speed = walking_speed
	
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
