@tool
class_name LinePolePlacer
extends RefCounted

## Distribui e instancia os postes ao longo da linha baseando-se nas regras de RNG.
static func create_poles(
	pole_scene: PackedScene,
	container: Node2D,
	start_pos: Vector2,
	end_pos: Vector2,
	params: Dictionary,
	scene_root: Node
) -> Array[Node2D]:
	var spawned_poles: Array[Node2D] = []
	var direction := (end_pos - start_pos).normalized()
	var total_distance := start_pos.distance_to(end_pos)
	
	if total_distance < params.min_distance:
		return spawned_poles
	
	var rng := RandomNumberGenerator.new()
	rng.seed = params.generation_seed
	
	var current_distance := 0.0
	
	while current_distance < total_distance:
		var step = rng.randf_range(params.min_distance, params.max_distance)
		current_distance += step
		
		if current_distance >= total_distance:
			break
			
		var base_pos := start_pos + (direction * current_distance)
		
		# Aplicação de variações físicas pontuais
		base_pos.x += rng.randf_range(-params.x_var, params.x_var)
		base_pos.y += rng.randf_range(-params.y_var, params.y_var)
		var random_rot := deg_to_rad(rng.randf_range(-params.rot_var, params.rot_var))
		
		# Trava de altura mínima
		if params.use_min_height:
			base_pos.y = min(base_pos.y, params.min_pole_height)
		
		#if params.use_max_height: base_pos.y = max(base_pos.y, params.max_pole_height)
		
		# Instanciação limpa
		var pole = pole_scene.instantiate() as Node2D
		container.add_child(pole)
		
		if Engine.is_editor_hint() and scene_root:
			pole.owner = scene_root
		
		pole.position = base_pos
		pole.rotation = random_rot
		spawned_poles.append(pole)
		
		if spawned_poles.size() >= params.max_poles:
			break
	
	return spawned_poles
