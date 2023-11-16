extends Polygon2D

@export var char1: CharacterBody2D
@export var char2: CharacterBody2D
@export var conversation_store = []
var currently_speaking = null
var show_dialog_box = false
var page = 0

func _ready():
	$Control.hide()

func _input(event):
	var just_pressed = event.is_pressed() and not event.is_echo()
	if Input.is_key_pressed(KEY_ENTER) and just_pressed:
		conversation_loop()

func set_characters(c1, c2):
	char1 = c1
	char2 = c2
	currently_speaking = char1
	
func render_dialog_box():
	$Control/DialogHeader.text = conversation_store[page]['character_name']
	$Control/DialogBody.text = conversation_store[page]['content']
	$Control.show()	
	page = page + 1
	
func begin_conversation():
	$Timer.start()

func conversation_loop():
	print('In conversation loop!')
	conversation_store.append(
		{
			'character_name':currently_speaking.character_name,
			'content':currently_speaking.get_response(conversation_store)
		}
	)
	print(conversation_store)
	if show_dialog_box:
		render_dialog_box()
	currently_speaking = char1 if currently_speaking == char2 else char2	
	if char1.name == 'Character2DAdam' or char2.name == 'Character2DAdam':
		return
	conversation_loop()

func _on_timer_timeout():
	conversation_loop()
