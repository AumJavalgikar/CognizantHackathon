extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D
@export var speed = 200
var current_idle_animation = 'idle_down'

func _process(_delta):
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
		if current_idle_animation == 'idle_left':
			_animated_sprite.flip_h = true
			_animated_sprite.play("idle_right")	
				
		else:
			_animated_sprite.play(current_idle_animation)
		velocity.x = 0
		velocity.y = 0
			
	move_and_slide()
		
