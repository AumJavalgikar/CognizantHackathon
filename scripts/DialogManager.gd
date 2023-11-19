extends Node

var conversations = []
var conversation_scene = preload("res://scenes/conversation.tscn")
@onready var ConversationTab = get_tree().get_root().get_node('Map/MainMenu').get_node('MainTab').get_node('Conversations').get_node('ConversationTab')

func initiate_conversation(char1, char2):
	var instance = conversation_scene.instantiate()
	instance.set_characters(char1, char2)
	
	# Connect signal of instanced object to function
	var sig = instance.end_conversation
	sig.connect(_on_conversation_end_conversation)
	#add_child(instance)
	
	var button = Button.new()
	button.name = char1.character_name + ' & ' + char2.character_name
	
	var vbox = VBoxContainer.new()
	
	button.size = Vector2(1096, 466)
	vbox.size = Vector2(1096, 466)
	
	vbox.add_child(instance)
	button.add_child(vbox)
	ConversationTab.add_child(button)
	char1.in_conversation = true
	char2.in_conversation = true
	
	if char1.name == 'Character2DAdam' or char2.name == 'Character2DAdam':
		instance.show_dialog_box = true
		
	instance.begin_conversation()
	
	# Not doing anything with this yet
	print('Added child to dialog manager :', instance, ' With char1 :', instance.char1, ' char2 :', instance.char2)
	conversations.append({char1.name + ',' + char2.name: instance})
	print(conversations)



func _on_conversation_end_conversation(conversation, char1, char2):
	char1.in_conversation = false
	char2.in_conversation = false
	
	# Not sure about deleting the conversation, leave this up for future work
	conversation.queue_free()
