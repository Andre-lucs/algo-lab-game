extends Node
class_name LevelExecutor

# Este script cuida da execução dos paths e valida a solução do jogador

# Sinais para feedback da UI
signal execution_started
signal execution_finished(success: bool)

var level : Level = null
var execution_in_progress: bool = false

func _ready() -> void:
	# Conecta os sinais de execução
	var parent = get_parent()
	if parent == null:
		printerr("LevelExecutor: Parent node not found.")
		return
	
	if parent is Level:
		level = parent as Level
	else:
		printerr("LevelExecutor: Parent node is not a Level.")
		return

func start_execution():
	if execution_in_progress:
		return
	reset_level()
	execution_in_progress = true
	emit_signal("execution_started")
	activate_automatic_items()

func activate_automatic_items():
	get_tree().call_group("activation", "start_activation_if_auto")

func finish_execution(success: bool):
	if not execution_in_progress:
		return
	execution_in_progress = false
	get_tree().call_group("activation", "reset")
	print("level concluido" if success else "level falhou")
	execution_finished.emit(success)
		

func reset_level():
	print("Resetando o nível...")
	execution_in_progress = false
	get_tree().call_group("activation", "pause_activation")
	
	# Resetar validadores
	level.validators_finished = 0
	
	get_tree().call_group("resettable", "reset")  # Reseta todos os resettable
