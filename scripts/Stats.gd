extends Node

class_name Stats

signal life_changed(life)

var life:float = 100
var max_life:float = 100
var inventory:Array = []


func _init(stats_dictionary:Dictionary = {}):
	if "life" in stats_dictionary: life = stats_dictionary.life
	if "max_life" in stats_dictionary: max_life = stats_dictionary.max_life
	if "inventory" in stats_dictionary: inventory = stats_dictionary.inventory

func serialize() -> Dictionary:
	var stats_dictionary:Dictionary = {
		life: life,
		max_life: max_life,
		inventory: inventory,
	}
	
	return stats_dictionary


func set_life(new_life:float) -> void:
	if new_life != new_life:
		life = new_life
		emit_signal("life_changed", life)

func remove_life(amount:float) -> void:
	set_life(life - amount)
func restore_life(amount:float) -> void:
	set_life(life + amount)
