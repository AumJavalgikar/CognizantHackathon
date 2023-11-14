extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D
@export var speed = 200
var current_idle_animation = 'idle_down'
func _ready():
	$interact_prompt.hide()

func _process(_delta):
	if $"RayCast2D".is_colliding():
		var object = $RayCast2D.get_collider()
		print('Colliding with ', object, '!')
		
		if object.is_in_group("NPC"): 
			print('Colliding with NPC!')
			$interact_prompt.show()
			if Input.is_action_pressed('interact'):
				object.talk()
		else:
			$interact_prompt.hide()
	else:
		$interact_prompt.hide()
				
	if Input.is_action_pressed("ui_right"):
		$RayCast2D.target_position.x = 8
		$RayCast2D.target_position.y = 0
		_animated_sprite.flip_h = false		
		velocity.x = speed + 50
		velocity.y = 0
		_animated_sprite.play("run_right")
		current_idle_animation = 'idle_right'
		
	elif Input.is_action_pressed("ui_up"):
		$RayCast2D.target_position.x = 0
		$RayCast2D.target_position.y = -8
		velocity.y = -speed	
		velocity.x = 0			
		_animated_sprite.play("run_up")
		current_idle_animation = 'idle_up'
		
	elif Input.is_action_pressed("ui_down"):
		$RayCast2D.target_position.x = 0
		$RayCast2D.target_position.y = 8
		velocity.y = speed
		velocity.x = 0					
		_animated_sprite.play("run_down")
		current_idle_animation = 'idle_down'
		
	elif Input.is_action_pressed("ui_left"):
		$RayCast2D.target_position.x = -8
		$RayCast2D.target_position.y = 0
		_animated_sprite.flip_h = true
		_animated_sprite.play("run_right")		
		velocity.x = -(speed + 50)
		velocity.y = 0		
		current_idle_animation = 'idle_left'
		
	else:
		if current_idle_animation == 'idle_left':
			_animated_sprite.flip_h = true
			_animated_sprite.play("idle_right")	
				
		else:
			_animated_sprite.play(current_idle_animation)
		velocity.x = 0
		velocity.y = 0
			
	move_and_slide()
		
