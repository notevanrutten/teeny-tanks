extends CharacterBody2D

const MOVEMENT_SPEED = 250.0
const ROTATION_SPEED = 3.0

const LABEL_OFFSET_X = 50.0
const LABEL_OFFSET_Y = 70.0

const BULLET_OFFSET = 40.0
const RELOAD_TIME = 0.5

var bullet_scene = preload("res://scenes/bullet.tscn")
var shield_scene = preload("res://scenes/shield.tscn")

func _ready():
	$Networking/MultiplayerSynchronizer.set_multiplayer_authority(int(str(name)))
	$Camera2D.current = is_local_authority()
	$Label.set_as_top_level(true)
	$Label.text = name
	
	$Timer.wait_time = RELOAD_TIME
	
	if is_local_authority():
		randomize()
		var r = randf_range(0.2, 1.0)
		var g = randf_range(0.2, 1.0)
		var b = randf_range(0.2, 1.0)
		modulate = Color(r, g, b)
		$Networking.sync_modulate = modulate

func _physics_process(delta):
	if not is_local_authority():
		position = $Networking.sync_position
		rotation = $Networking.sync_rotation
		modulate = $Networking.sync_modulate
		update_label()
		return
	
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
	update_label()
	
	$Networking.sync_position = position
	$Networking.sync_rotation = rotation

func is_local_authority() -> bool:
	return $Networking/MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id()

func update_label() -> void:
	$Label.set_global_position(Vector2(global_position.x - LABEL_OFFSET_X, global_position.y - LABEL_OFFSET_Y))

@rpc(any_peer, call_local, reliable)
func shoot(spawner: StringName) -> void:
	var bullet = bullet_scene.instantiate()
	bullet.spawner = spawner
	bullet.position = global_position + Vector2(0, -BULLET_OFFSET).rotated(global_rotation)
	bullet.rotation = global_rotation
	get_node("/root/Main/SpawnPath").add_child(bullet, true)

@rpc(any_peer, call_local, reliable)
func hit() -> void:
	var shield = shield_scene.instantiate()
	add_child(shield)
