extends CharacterBody2D

const MOVEMENT_SPEED = 250.0
const ROTATION_SPEED = 3.0

const LABEL_OFFSET_X = 60.0
const LABEL_OFFSET_Y = 70.0

const BULLET_OFFSET = 43.0
const RELOAD_TIME = 1.0
const RESPAWN_TIME = 5.0

var bullet_scene = preload("res://scenes/bullet.tscn")
var explosion_scene = preload("res://scenes/explosion.tscn")

@export var score: int
@export var invincibility: bool

func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(int(str(name)))
	$Camera2D.current = $MultiplayerSynchronizer.is_multiplayer_authority()
	
	$Label.set_as_top_level(true)
	$Label.text = name
	
	$ReloadTimer.wait_time = RELOAD_TIME
	$RespawnTimer.wait_time = RESPAWN_TIME
	
	if $MultiplayerSynchronizer.is_multiplayer_authority():
		randomize()
		var r = randf_range(0.2, 1.0)
		var g = randf_range(0.2, 1.0)
		var b = randf_range(0.2, 1.0)
		$Sprite2D.modulate = Color(r, g, b)
		
		score = 0
		respawn()

func _physics_process(delta):
	if $MultiplayerSynchronizer.is_multiplayer_authority():
		if not $RespawnTimer.is_stopped():
			visible = false
			$CollisionShape2D.disabled = true
			update_synchronizer()
			return
		
		if Input.is_action_just_pressed("mouse_1") && $ReloadTimer.is_stopped():
			$ReloadTimer.start()
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
		
		$Label.position = Vector2(position.x - LABEL_OFFSET_X, position.y - LABEL_OFFSET_Y)
		
		update_synchronizer()

func respawn() -> void:
	randomize()
	position = get_node("/root/Main/Spawn").get_child(randi_range(0,3)).position
	rotation = 0
	$AnimationPlayer.play("respawn")

@rpc(any_peer, call_local, reliable)
func shoot(spawner: StringName) -> void:
	var bullet = bullet_scene.instantiate()
	bullet.spawner = spawner
	bullet.position = position + Vector2(0, -BULLET_OFFSET).rotated(rotation)
	bullet.rotation = rotation
	get_node("/root/Main/Bullets").add_child(bullet, true)

func update_synchronizer() -> void:
	$MultiplayerSynchronizer.position = position
	$MultiplayerSynchronizer.rotation = rotation
	$MultiplayerSynchronizer.visibile = visible
	$MultiplayerSynchronizer.invincibility = invincibility
	$MultiplayerSynchronizer.collision = $CollisionShape2D.disabled
	$MultiplayerSynchronizer.modulate = $Sprite2D.modulate
	$MultiplayerSynchronizer.shield_modulate = $Shield.modulate

@rpc(any_peer, call_local, reliable)
func hit() -> void:
	score = 0
	$RespawnTimer.start()
	rpc_id(1, "explode")

func _on_respawn_timer_timeout():
	visible = true
	$CollisionShape2D.disabled = false
	respawn()

@rpc(any_peer, call_local, reliable)
func explode() -> void:
	var explosion = explosion_scene.instantiate()
	explosion.position = position
	get_node("/root/Main/Explosions").add_child(explosion, true)
