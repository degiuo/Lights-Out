extends Node3D

@onready var cam = $"."
@onready var player = $".."
@onready var see_raycast: RayCast3D = $Camera3D/SeeRay
@onready var pickup_point: Node3D = $Camera3D/pickup_point
var buy = preload("res://scenes/buy.tscn")

var v = Vector3()
const mouse_sens = 0.25

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	cam.rotation_degrees.x = v.x
	player.rotation_degrees.y = v.y
	
	if see_raycast.is_colliding():
		var target = see_raycast.get_collider()
		if target and target.has_method("interact"):
			if Input.is_action_just_pressed("pickup"):
				var instance = buy.instantiate()
				pickup_point.add_child(instance)

func _input(event):
	if event is InputEventMouseMotion:
		v.y += (-event.relative.x * mouse_sens)
		v.x += (-event.relative.y * mouse_sens)
		v.x = clamp(v.x, -80, 90)
