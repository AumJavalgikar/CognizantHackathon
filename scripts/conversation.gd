extends Node2D

@export var char1: CharacterBody2D
@export var char2: CharacterBody2D
var conversation_store = []
var dialog_boxes = [] 
var dialog_box_right = preload('res://scenes/dialog_box_right.tscn')
var dialog_box_left = preload('res://scenes/dialog_box_left.tscn')
var currently_speaking = null
var show_dialog_box = false
signal end_conversation


func _ready():
	pass

func _input(event):
	if char1 == null:
		return
	if char1.name != 'Character2DAdam' and char2.name != 'Character2DAdam':
		return
	var just_pressed = event.is_pressed() and not event.is_echo()
	if Input.is_key_pressed(KEY_ENTER) and just_pressed:
		conversation_loop()	
	if Input.is_key_pressed(KEY_ESCAPE) and just_pressed:
		show_dialog_box = false
		hide_dialog_boxes()
		if char1.name == 'Character2DAdam' or char2.name == 'Character2DAdam':
			print('Emitted conversation_end')
			end_conversation.emit(self, char1, char2)

func set_characters(c1, c2):
	char1 = c1
	char2 = c2
	currently_speaking = char1
	
func create_dialog_box(character_name, content):
	var dialog_box = dialog_box_left if currently_speaking == char1 else dialog_box_right
	var dialog_box_instance = dialog_box.instantiate()
	dialog_box_instance.set_contents(character_name, content)
	
	dialog_boxes.push_front(dialog_box_instance)
	
	add_child(dialog_box_instance)

	if show_dialog_box:
		show_next_dialog_box()
	
func begin_conversation():
	$Timer.start()

func show_next_dialog_box():
	print('In next dialog box')
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_parallel(true)
	dialog_boxes[0].position.y = 343
	dialog_boxes[0].modulate.a8 = 0
	tween.tween_property(dialog_boxes[0], 'modulate:a8', 255, 1)
	for i in range(min(len(dialog_boxes), 4)):
		var box = dialog_boxes[i]
		tween.tween_property(box, 'position:y', 343 - (i * 100), 1)
		#box.position.y = 550 - (i * 125)
		#tween.tween_property(box, 'modulate:a8', 255 - (i * 50), 1)
		#box.modulate.a8 = 255 - (i * 50)
		print('Set property of dialog box : ', i)
		if show_dialog_box:
			box.show()
	
	while len(dialog_boxes) > 4:
		print('dialog box is over 4!')
		var box = dialog_boxes.pop_back()
		tween.tween_property(box, 'modulate:a8', 0, 1)
		tween.set_parallel(false)
		tween.tween_callback(box.queue_free)
		tween.set_parallel(true)

func show_dialog_boxes():
	for dialog_box in dialog_boxes:
		dialog_box.show()

func hide_dialog_boxes():
	for box in dialog_boxes:
		box.hide()

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

func _on_timer_timeout():
	conversation_loop() 
