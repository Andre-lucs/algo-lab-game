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
	execution_in_progress = true
	emit_signal("execution_started")
	activate_automatic_items()

func activate_automatic_items():

	var activatables = get_tree().get_nodes_in_group("activation").filter(func(a): return a is Activatable)

	for activatable in activatables:
		if activatable is Activatable:
			activatable.start_activation_if_auto()

func finish_execution(success: bool):
	if not execution_in_progress:
		return
	execution_in_progress = false
	print("level concluido" if success else "level falhou")
	emit_signal("execution_finished", success)
	execution_finished.emit(success)
		

func reset_level():
	print("Resetando o nível...")
	execution_in_progress = false
	
	# Resetar validadores
	level.validators_finished = 0
	
	var resetabbles = get_tree().get_nodes_in_group("resetabble")

	for resettable in resetabbles:
		if resettable.has_method("reset"):
			resettable.reset()  # se tiver lógica de animação ou estado interno
