extends Node2D

func _ready():
	$Timer.start()
	hide()

func set_contents(header, body):
	$Control/DialogBody.text = body
	$Control/DialogHeader.text = header


func _on_timer_timeout():
	if $Control/DialogBody.visible_characters == len($Control/DialogBody.text):
		$Timer.stop
	else:
		$Control/DialogBody.visible_characters += 1
