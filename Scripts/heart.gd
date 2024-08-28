extends Area2D

# NOTE: This was connected in the editor
func _on_area_entered(area):
	queue_free()


func _on_body_entered(body):
	queue_free()
	var hearts: Array = get_tree().get_nodes_in_group("Hearts")
	
	print("hearts left: " + str(hearts.size()))
	
	# 1 instead of 0 because it doesnt free the last one til after # hearts is printed
	if hearts.size() == 1:
		Events.level_complete.emit()

