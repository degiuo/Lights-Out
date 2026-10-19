extends StaticBody3D

@export var item_scene: PackedScene 

var is_empty: bool = false

func interact(player: Node):
	if is_empty:
		print("Полка пуста.")
		return
		
	if player.pick_up(item_scene):
		is_empty = true
		print("Взял еду с полки.")
