extends Node3D

@onready var phone_sprite = $Sprite3D
@onready var phone_flashlight = $Sprite3D/flashlight

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("ui_phone"):
		phone_sprite.visible = not phone_sprite.visible
	
	if Input.is_action_pressed("flashlight") and phone_sprite.visible == true:
		phone_flashlight.visible = not phone_flashlight.visible
