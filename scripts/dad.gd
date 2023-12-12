extends CharacterBody2D

@export var movement_speed: float = 8000
@export var character_name = 'Dad'
@onready var navigation_agent: NavigationAgent2D = get_node("NavigationAgent2D")
@onready var tile_map: TileMap = get_tree().get_root().get_node("Map/TileMap")
@onready var aStar: AStar2D = tile_map.get("aStar")
var responses = ['Hello!', 'Nice Weather today!', 'Indeed!', 'I wonder where my keys are..']
var page = 0
var movement_delta: float 
var traversing_path = false
var path = []
var nextPoint = null
var idle_direction = 'idle_down'
var in_conversation = false
var locations = {
	'Refrigerator(Kitchen)' : [17,2],
	'TV(Living room)' : [3, 3],
	'Bed(Bedroom)' : [19, 11],
	'Sink(Kitchen)' : [19, 2],
	'Toy Train Set(Living room)' : [6, 11],
	'Table(Living room)' : [4, 6],
	'Table(Bedroom)' : [16, 7],
	'Table(Kitchen)' :[9, 3]
}
var last_location = 'Table(Living room)'
var last_action = 'idle'

func getAStarCellId(vCell:Vector2)->int:
	return int(vCell.y+vCell.x*tile_map.get_used_rect().size.y)

func _ready():
	$AnimatedSprite2D2.play("idle_down")
	$Thinking.hide()
	get_next_action()
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))

func _input(event):
	if event is InputEventMouseButton:
		var pos = event.position
		set_movement_target(tile_map.local_to_map(pos))
		
func set_movement_target(target_pos):
	var startIdx = getAStarCellId(tile_map.local_to_map(global_position))
	var endIdx = getAStarCellId(target_pos)
	path = Array(aStar.get_point_path(startIdx, endIdx))
	traversing_path = true
	nextPoint = path.pop_front()
	#navigation_agent.set_target_position(get_global_mouse_position())

func _physics_process(delta):
	if in_conversation:
		$AnimatedSprite2D2.play(idle_direction)
		return
	if not traversing_path:
		$AnimatedSprite2D2.play(idle_direction)
		return
	if navigation_agent.is_navigation_finished() and len(path) > 0:
		nextPoint = path.pop_front()
		navigation_agent.set_target_position(Vector2(nextPoint[0], nextPoint[1]))
	elif navigation_agent.is_navigation_finished() and len(path) == 0:
		traversing_path = false
	
	
	movement_delta = movement_speed * delta
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var current_agent_position: Vector2 = global_position
	var new_velocity: Vector2 = (next_path_position - current_agent_position).normalized() * movement_delta
	
	_on_velocity_computed(new_velocity)
	
	# Play animation
	if (current_agent_position.x - next_path_position.x) < -10:
		$AnimatedSprite2D2.flip_h = false		
		$AnimatedSprite2D2.play("run_right")
		idle_direction = 'idle_right'
	elif (current_agent_position.x - next_path_position.x) > 10:
		$AnimatedSprite2D2.flip_h = true
		$AnimatedSprite2D2.play("run_right")
		idle_direction = 'idle_right'
	elif (current_agent_position.y - next_path_position.y) > 10:
		$AnimatedSprite2D2.play("run_up")
		idle_direction = 'idle_up'
	elif (current_agent_position.y - next_path_position.y) < -10:
		$AnimatedSprite2D2.play("run_down")
		idle_direction = 'idle_down'
		
	#print('Next position :', next_path_position)
	#print('Global position :', global_position)
	#print('movement delta :', movement_delta)
	#print('next path position: ', navigation_agent.get_next_path_position(), 'velocity :', new_velocity)
		
func get_response(conversation_store):
	var response = responses[page]
	page = (page + 1) % len(responses)
	return response

func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity
	move_and_slide()
#'character_name' : 'character1_name',
#    'current_time': 'time',
 #   'other_character_status' : 'statuses'
func get_next_action():
	$Thinking.show()
	$Thinking.play("default")
	$HTTPRequest.request("http://127.0.0.1:8000/getAction/", [], HTTPClient.METHOD_GET, JSON.new().stringify({'character_name' : self.character_name,
	'current_time': '[8: 00 pm]',
	'other_character_status': 'Unknown',
	'last_location' : last_location,
	'last_action' : last_action}))

func _on_http_request_request_completed(result, response_code, headers, body):
	$Thinking.hide()
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	var move_to = response['move_to']
	var action = response['action']
	
	self.last_location = move_to
	self.last_action = action
	
	$ThinkingControl/ThinkingLabel.text = action
	set_movement_target(get_location_coords(move_to))

func get_location_coords(move_to):
	var cell = self.locations[move_to]
	return Vector2i(cell[0], cell[1])


func _on_action_timer_timeout():
	if !in_conversation:
		get_next_action()
