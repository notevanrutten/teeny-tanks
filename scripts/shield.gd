extends StaticBody2D

func _ready():
	$Sprite2D.modulate = Color(1, 1, 1)

func _physics_process(delta):
	get_node("../MultiplayerSynchronizer").shield_modulate = $Sprite2D.modulate
	get_node("../MultiplayerSynchronizer").shield_collision = $CollisionShape2D.disabled
