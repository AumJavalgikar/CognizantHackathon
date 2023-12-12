extends Control

var tween

func _ready():
	position = Vector2(3, 648)

func enable_button():
	$Button.disabled = false

func _on_button_pressed():
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUINT)
	if position.y == 648:
		#$TileMap.show()
		$Button.disabled = true
		tween.tween_property(self, "position", Vector2(3, 72), 2)
		tween.tween_callback(enable_button)		
		
	else:
		$Button.disabled = true				
		tween.tween_property(self, "position", Vector2(3, 648), 2)
		tween.tween_callback(enable_button)			
