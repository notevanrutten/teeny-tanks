extends Node

var player_scene = preload("res://scenes/player.tscn")
var player_list

func _enter_tree():
	if "--server" in OS.get_cmdline_args():
		start_network(true)
	else:
		start_network(false)

func start_network(server: bool) -> void:
	var peer = WebSocketMultiplayerPeer.new()
	if server:
		multiplayer.peer_connected.connect(self.create_player)
		multiplayer.peer_disconnected.connect(self.destroy_player)
		peer.create_server(9999)
	else:
		peer.create_client("localhost:" + str(9999))
	multiplayer.set_multiplayer_peer(peer)

func create_player(id: int) -> void:
	var player = player_scene.instantiate()
	player.name = str(id)
	add_child(player)

func destroy_player(id: int) -> void:
	get_node(str(id)).queue_free()
