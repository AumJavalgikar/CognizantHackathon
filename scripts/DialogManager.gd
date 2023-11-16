extends Node

var conversations = []
var conversation_scene = preload("res://scenes/conversation.tscn")

func initiate_conversation(char1, char2):
	var instance = conversation_scene.instantiate()
	instance.set_characters(char1, char2)
	add_child(instance)
	if char1.name == 'Character2DAdam' or char2.name == 'Character2DAdam':
		instance.show_dialog_box = true
	instance.begin_conversation()
	print('Added child to dialog manager :', instance, ' With char1 :', instance.char1, ' char2 :', instance.char2)
	conversations.append({char1.name + ',' + char2.name: instance})
	print(conversations)
