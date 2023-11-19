extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D
@export var speed = 200
@export var character_name = 'Adam'
var responses = ['Hey dad!', 'Hows it going?', 'Huh?', 'I dunno']
var page = 0
@onready var dialog_manager = get_tree().get_root().get_node("Map/DialogManager")
var current_idle_animation = 'idle_down'
var in_conversation = false

func _ready():
	$interact_prompt.hide()

func is_raycast_colliding():
	if current_idle_animation == 'idle_right':
		if $Raycasts/RayCastright1.is_colliding():
			return $Raycasts/RayCastright1.get_collider()
		if $Raycasts/RayCastright2.is_colliding():
			return $Raycasts/RayCastright2.get_collider()
		if $Raycasts/RayCastright3.is_colliding():
			return $Raycasts/RayCastright3.get_collider()
	if current_idle_animation == 'idle_left':
		if $Raycasts/RayCastleft1.is_colliding():
			return $Raycasts/RayCastleft1.get_collider()
		if $Raycasts/RayCastleft2.is_colliding():
			return $Raycasts/RayCastleft2.get_collider()
		if $Raycasts/RayCastleft3.is_colliding():
			return $Raycasts/RayCastleft3.get_collider()
	if current_idle_animation == 'idle_up':
		if $Raycasts/RayCastup1.is_colliding():
			return $Raycasts/RayCastup1.get_collider()
		if $Raycasts/RayCastup2.is_colliding():
			return $Raycasts/RayCastup2.get_collider()
		if $Raycasts/RayCastup3.is_colliding():
			return $Raycasts/RayCastup3.get_collider()
	if current_idle_animation == 'idle_down':
		if $Raycasts/RayCastdown1.is_colliding():
			return $Raycasts/RayCastdown1.get_collider()
		if $Raycasts/RayCastdown2.is_colliding():
			return $Raycasts/RayCastdown2.get_collider()
		if $Raycasts/RayCastdown3.is_colliding():
			return $Raycasts/RayCastdown3.get_collider()

func play_idle_animation():
	if current_idle_animation == 'idle_left':
			_animated_sprite.flip_h = true
			_animated_sprite.play("idle_right")	
				
	else:
		_animated_sprite.play(current_idle_animation)

func _process(_delta):
	if in_conversation:
		return
		
	var colliding_object = is_raycast_colliding()
	if colliding_object != null:
		if colliding_object.is_in_group("NPC"): 
			$interact_prompt.show()
			if Input.is_action_just_pressed('interact'):
				dialog_manager.initiate_conversation(self, colliding_object)
				$interact_prompt.hide()
				play_idle_animation()				
		else:
			$interact_prompt.hide()
	else:
		$interact_prompt.hide()
	
				
	if Input.is_action_pressed("ui_right"):
		_animated_sprite.flip_h = false		
		velocity.x = speed + 50
		velocity.y = 0
		_animated_sprite.play("run_right")
		current_idle_animation = 'idle_right'
		
	elif Input.is_action_pressed("ui_up"):
		velocity.y = -speed	
		velocity.x = 0			
		_animated_sprite.play("run_up")
		current_idle_animation = 'idle_up'
		
	elif Input.is_action_pressed("ui_down"):
		velocity.y = speed
		velocity.x = 0					
		_animated_sprite.play("run_down")
		current_idle_animation = 'idle_down'
		
	elif Input.is_action_pressed("ui_left"):
		_animated_sprite.flip_h = true
		_animated_sprite.play("run_right")		
		velocity.x = -(speed + 50)
		velocity.y = 0		
		current_idle_animation = 'idle_left'
		
	else:
		play_idle_animation()
		velocity.x = 0
		velocity.y = 0
			
	move_and_slide()
	
func get_response(conversation_store):
	var response = responses[page]
	page = (page + 1) % len(responses)
	return response
