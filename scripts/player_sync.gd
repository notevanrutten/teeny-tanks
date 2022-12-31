extends MultiplayerSynchronizer

@export var position: Vector2:
	set(value):
		if is_multiplayer_authority():
			position = value
		else:
			get_parent().position = value
			get_node("../Label").position = Vector2(value.x - get_parent().LABEL_OFFSET_X, value.y - get_parent().LABEL_OFFSET_Y)

@export var rotation: float:
	set(value):
		if is_multiplayer_authority():
			rotation = value
		else:
			get_parent().rotation = value

@export var visibile: bool:
	set(value):
		if is_multiplayer_authority():
			visibile = value
		else:
			get_parent().visible = value

@export var invincibility: bool:
	set(value):
		if is_multiplayer_authority():
			invincibility = value
		else:
			get_parent().invincibility = value

@export var collision: bool:
	set(value):
		if is_multiplayer_authority():
			collision = value
		else:
			get_node("../CollisionShape2D").disabled = value

@export var modulate: Color:
	set(value):
		if is_multiplayer_authority():
			modulate = value
		else:
			get_node("../Sprite2D").modulate = value

@export var shield_modulate: Color:
	set(value):
		if is_multiplayer_authority():
			shield_modulate = value
		else:
			get_node("../Shield").modulate = value
