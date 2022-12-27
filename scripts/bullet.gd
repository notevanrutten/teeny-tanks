extends CharacterBody2D

const SPEED = 350.0

var spawner: StringName

func _ready():
	velocity = Vector2(0, -SPEED).rotated(rotation)

func _physics_process(delta):
	var collide = move_and_collide(velocity * delta)
	if collide:
		velocity = velocity.bounce(collide.get_normal())
		rotation = velocity.angle() + PI/2
