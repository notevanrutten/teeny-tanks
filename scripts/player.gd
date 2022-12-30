extends CharacterBody2D

const MOVEMENT_SPEED = 250.0
const ROTATION_SPEED = 3.0

const LABEL_OFFSET_X = 60.0
const LABEL_OFFSET_Y = 70.0

const BULLET_OFFSET = 43.0
const RELOAD_TIME = 1.0

var bullet_scene = preload("res://scenes/bullet.tscn")

func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(int(str(name)))
	$Camera2D.current = $MultiplayerSynchronizer.is_multiplayer_authority()
	
	$Label.set_as_top_level(true)
	$Label.text = name
	
	$Timer.wait_time = RELOAD_TIME
	
	if $MultiplayerSynchronizer.is_multiplayer_authority():
		randomize()
		var r = randf_range(0.2, 1.0)
		var g = randf_range(0.2, 1.0)
		var b = randf_range(0.2, 1.0)
		$Sprite2D.modulate = Color(r, g, b)
		$MultiplayerSynchronizer.modulate = Color(r, g, b)
		
		respawn()

func _physics_process(delta):
	if $MultiplayerSynchronizer.is_multiplayer_authority():
		if Input.is_action_just_pressed("mouse_1") && $Timer.is_stopped():
			$Timer.start()
			rpc_id(1, "shoot", name)
		
		velocity = Vector2.ZERO
		if Input.is_action_pressed("left"):
			rotation -= ROTATION_SPEED * delta
		if Input.is_action_pressed("right"):
			rotation += ROTATION_SPEED * delta
		if Input.is_action_pressed("up"):
			velocity = Vector2(0, -MOVEMENT_SPEED).rotated(rotation)
		if Input.is_action_pressed("down"):
			velocity = Vector2(0, +MOVEMENT_SPEED).rotated(rotation)
		move_and_slide()

		$MultiplayerSynchronizer.position = position
		$MultiplayerSynchronizer.rotation = rotation
		
		$Label.position = Vector2(position.x - LABEL_OFFSET_X, position.y - LABEL_OFFSET_Y)

@rpc(any_peer, call_local, reliable)
func shoot(spawner: StringName) -> void:
	var bullet = bullet_scene.instantiate()
	bullet.spawner = spawner
	bullet.position = position + Vector2(0, -BULLET_OFFSET).rotated(rotation)
	bullet.rotation = rotation
	get_node("/root/Main").add_child(bullet, true)

func respawn() -> void:
	randomize()
	position = get_node("/root/Main/Spawn").get_child(randi_range(0,3)).position
	$Shield/AnimationPlayer.play("spawn")
