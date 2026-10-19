extends Node3D

@onready var cam = $"."
@onready var player = $".."

var v = Vector3()
const mouse_sens = 0.25

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	cam.rotation_degrees.x = v.x
	player.rotation_degrees.y = v.y

func _input(event):
	if event is InputEventMouseMotion:
		v.y += (-event.relative.x * mouse_sens)
		v.x += (-event.relative.y * mouse_sens)
		v.x = clamp(v.x, -80, 90)
