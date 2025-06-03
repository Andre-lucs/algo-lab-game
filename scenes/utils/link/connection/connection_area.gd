## Dependendo da layer em que a area esteja pode ser utilizado para diferentes tipos de conexões.
class_name ConnectionArea
extends Area2D

@export var sends : bool = true
@export var receives : bool = true
@export var sticks_to_center : bool = true
@export var activatable : Activatable = null
@export var number_movement : NumberMovement = null
