extends Node2D

@export var char1: CharacterBody2D
@export var char2: CharacterBody2D
var conversation_store = []
var dialog_boxes = [] 
var dialog_box_right = preload('res://scenes/dialog_box_right.tscn')
var dialog_box_left = preload('res://scenes/dialog_box_left.tscn')
var currently_speaking = null
var show_dialog_box = false
var reason_for_conversation = 'unknown'
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
	#var dialog_box = dialog_box_left if currently_speaking == char1 else dialog_box_right
	#var dialog_box_instance = dialog_box.instantiate()
	#dialog_box_instance.set_contents(character_name, content)
	var dialog_box_instance = Label.new()
	dialog_box_instance.z_index = 10
	dialog_box_instance.text = character_name + ' :' + content
	
	dialog_boxes.push_front(dialog_box_instance)
	
	get_parent().add_child(dialog_box_instance)

	#if show_dialog_box:
	#	show_next_dialog_box()
	
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
	if char1.name == 'Character2DAdam' or char2.name == 'Character2DAdam':
		return
	get_next_agent_response()
	return
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

func user_response_received(user_response):
	create_dialog_box(currently_speaking.character_name, user_response)
	
	self.conversation_store.push_front(
		{
			'character_name':currently_speaking.character_name,
			'content':user_response
		}
	)
	
	currently_speaking = char1 if currently_speaking == char2 else char2	
	
	get_next_agent_response()
	
func get_next_agent_response():
	print('Made HTTP request for next agent response')
	var character_name = currently_speaking.character_name
	var other_speaker = char1 if currently_speaking == char2 else char2
	var new_response = null
	var conversation_initiated = true
	var conversation_initiated_reason = self.reason_for_conversation
	
	if len(self.conversation_store) > 0:
		new_response = self.conversation_store[0]['content']
		conversation_initiated = false
		conversation_initiated_reason = null
		
	$HTTPRequest.request("http://127.0.0.1:8000/getConversationResponse/", [], HTTPClient.METHOD_GET, JSON.new().stringify(
	{
	'current_speaker': character_name,
	'other_speaker': other_speaker.character_name,
	'current_time': WorldClock.get_current_time(),
	'new_response': new_response,
	'conversation_initiated': conversation_initiated,
	'conversation_initiated_reason': conversation_initiated_reason,
	}
	))

func _on_timer_timeout():
	conversation_loop() 


func _on_http_request_request_completed(result, response_code, headers, body):
	print('Received HTTP response for the next response')
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	var conversation_response = response['conversation_response']
	
	create_dialog_box(currently_speaking.character_name, conversation_response)
	currently_speaking = char1 if currently_speaking == char2 else char2
	
	if currently_speaking.character_name == 'Adam':
		return
	else:
		get_next_agent_response()
