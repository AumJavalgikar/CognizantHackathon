extends Node2D

@export var char1: CharacterBody2D
@export var char2: CharacterBody2D
var conversation_store = []
var dialog_boxes = [] 
var dialog_box_right = preload('res://scenes/dialog_box_right.tscn')
var dialog_box_left = preload('res://scenes/dialog_box_left.tscn')
var currently_speaking = null
var show_dialog_box = false

func _ready():
	pass

func _input(event):
	var just_pressed = event.is_pressed() and not event.is_echo()
	if Input.is_key_pressed(KEY_ENTER) and just_pressed:
		conversation_loop()			

func set_characters(c1, c2):
	char1 = c1
	char2 = c2
	currently_speaking = char1
	
func create_dialog_box(character_name, content):
	var dialog_box = dialog_box_left if currently_speaking == char1 else dialog_box_right
	var dialog_box_instance = dialog_box.instantiate()
	dialog_box_instance.set_contents(character_name, content)
	add_child(dialog_box_instance)
	dialog_boxes.push_front(dialog_box_instance)
	
func begin_conversation():
	$Timer.start()

func render_dialog_boxes():
	for i in range(min(len(dialog_boxes), 4)):
		var box = dialog_boxes[i]
		box.position.y = 550 - (i * 125)
		box.modulate.a8 = 255 - (i * 50)
		box.show()
	
	while len(dialog_boxes) > 4:
		print('dialog box is over 4!')
		var box = dialog_boxes.pop_back()
		box.hide()
		box.queue_free

func conversation_loop():
	print('In conversation loop!')
	var character_name = currently_speaking.character_name
	var content = currently_speaking.get_response(conversation_store)
	conversation_store.push_front(
		{
			'character_name':character_name,
			'content':content
		}
	)
	
	create_dialog_box(character_name, content)
	
	#print(conversation_store)
	#print(dialog_boxes)	
	
	currently_speaking = char1 if currently_speaking == char2 else char2	
	if char1.name == 'Character2DAdam' or char2.name == 'Character2DAdam':
		return
	conversation_loop()

func _process(delta):
	if show_dialog_box:
		render_dialog_boxes()

func _on_timer_timeout():
	conversation_loop() 
