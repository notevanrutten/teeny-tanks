extends Node

var sync_position: Vector2:
	set(value):
		sync_position = value
		processed_position = false

var sync_velocity: Vector2
var sync_rotation: float
var sync_color: Color

var processed_position: bool
