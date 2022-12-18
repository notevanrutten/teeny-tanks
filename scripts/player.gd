extends CharacterBody2D

const MOVEMENT_SPEED = 300.0
const ROTATION_SPEED = 2.0

const LABEL_OFFSET_X = 50.0
const LABEL_OFFSET_Y = 70.0

func is_local_authority():
	return $Networking/MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id()

func _ready():
	$Networking/MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	$Camera2D.current = is_local_authority()
	$Label.set_as_top_level(true)
	$Label.text = name

func _physics_process(delta):
	if not is_local_authority():
		if not $Networking.processed_position:
			position = $Networking.sync_position
			$Networking.processed_position = true
		velocity = $Networking.sync_velocity
		rotation = $Networking.sync_rotation
		move_and_slide()
		update_label()
		return
	
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
	$Networking.sync_velocity = velocity
	$Networking.sync_rotation = rotation

func update_label() -> void:
	$Label.set_global_position(Vector2(position.x - LABEL_OFFSET_X, position.y - LABEL_OFFSET_Y))
