class_name Resettable extends Node

signal reset_requested

func _init() -> void:
	add_to_group("resettable")

func reset() -> void:
	reset_requested.emit()