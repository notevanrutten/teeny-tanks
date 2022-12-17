extends CharacterBody2D

const SPEED = 300

func is_local_authority():
	return $Networking/MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id()

func _ready():
	$Networking/MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	$Camera2D.current = is_local_authority()
	$UI/Label.text = name

func _physics_process(_delta):
	if not is_local_authority():
		if not $Networking.processed_position:
			position = $Networking.sync_position
			$Networking.processed_position = true
		velocity = $Networking.sync_velocity
		move_and_slide()
		return
	
	var direction = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	if direction:
		velocity = direction.normalized() * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
	move_and_slide()
	
	$Networking.sync_position = position
	$Networking.sync_velocity = velocity
