class_name Player;
extends CharacterBody3D

@export_group("Player playersettings")
@export var speed: float = 5.0;
@export var jump_speed: float = 5.0;
@export var sensitivity: float = 2.0;
@export_group("Dependencies")
@export var model: MaleBody = null;
@export var steps: Steps = null;
signal player_hurt;
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity");


func _physics_process(delta):
	# Add the gravity.
	apply_gravity(gravity * delta);
	if is_on_floor() && Input.is_action_just_pressed("jump"):
		velocity.y = jump_speed;

	var direction = get_direction();
	if  direction == Vector3.ZERO:
		_stop();
	else:
		if is_on_floor():
			_walk();
		else:
			_stop();
	apply_velocity(direction);
	move_and_slide();


func _walk():
	if model:
		model.walk();
	if steps:
		steps.walk();


func _stop():
	if model:
		model.idle();
	if steps:
		steps.stop();


func apply_velocity(direction: Vector3) -> void:
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * speed, speed);
		velocity.z = move_toward(velocity.z, direction.z * speed, speed);
	else:
		velocity.x = move_toward(velocity.x, 0, speed);
		velocity.z = move_toward(velocity.z, 0, speed);


func get_direction() -> Vector3:
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down");
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() * sensitivity;
	return direction;


func apply_gravity(gravity_value: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity_value;


func ouch():
	player_hurt.emit();
