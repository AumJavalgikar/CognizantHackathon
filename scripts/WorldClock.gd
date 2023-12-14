extends Node

var hour = 12
var minute = 55
var ampmIndicator = 'pm'

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	if minute == 55:
		minute = 0
		if hour == 11:
			ampmIndicator = 'am' if ampmIndicator == 'pm' else 'pm'
			hour += 1
		elif hour == 12:
			hour = 1
		else:
			hour += 1
	else:
		minute += 5
	print('new time : ' + get_current_time())

func get_current_time():
	return '[' + str(hour) + ' : ' + str(minute) + ' ' + ampmIndicator + ']'
