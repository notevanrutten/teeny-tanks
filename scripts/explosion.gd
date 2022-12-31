extends Node2D

const ANIMATION_TIME = 0.3

func _ready():
	if multiplayer.is_server():
		$Timer.wait_time = ANIMATION_TIME
		$Timer.start()
	$AnimatedSprite2D.play("default")

func _on_timer_timeout():
	if multiplayer.is_server():
		queue_free()
