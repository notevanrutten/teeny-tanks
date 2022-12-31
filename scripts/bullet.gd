extends CharacterBody2D

const SPEED = 350.0

var spawner: StringName

func _ready():
	if multiplayer.is_server():
		modulate = get_node("/root/Main/Players/" + spawner + "/Sprite2D").modulate
		velocity = Vector2(0, -SPEED).rotated(rotation)
	$AnimationPlayer.play("spawn")

func _physics_process(delta):
	if multiplayer.is_server():
		var collision = move_and_collide(velocity * delta)
		
		if collision:
			velocity = velocity.bounce(collision.get_normal())
			rotation = velocity.angle() + PI/2
			
			for i in range(0, get_node("/root/Main/Players").get_child_count()):
				var player = get_node("/root/Main/Players").get_child(i)
				
				if (collision.get_collider() == player) && (player.invincibility == false):
					player.rpc_id(int(str(player.name)), "hit")
					queue_free()
