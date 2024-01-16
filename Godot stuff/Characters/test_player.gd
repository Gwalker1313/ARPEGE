extends CharacterBody2D

@export var move_speed : float = 100
@export var starting_direction : Vector2 = Vector2(0,1)
@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

func _ready():
	update_animation_parameters(starting_direction)

func _physics_process(delta):
	#print($PlayerAudio/Timer.time_left)s
	# Get Input direction
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	update_animation_parameters(input_direction)
	
	# Update velocity:
	# If the player is pressing either "shift" key, give the player a sprint speed.
	if(Input.is_key_pressed(KEY_SHIFT)):
		velocity = input_direction * (move_speed + 50)
	else:
		velocity = input_direction * move_speed
	
	# Use walking sfx if the player is moving.
	if(velocity.length() == 0):
		# If the player is not moving, play "idle" sfx.
		#$PlayerAudio/Footstep_Gravel.play("Idle")
		pass
	elif($PlayerAudio/Timer.time_left <= 0.2):
		$PlayerAudio/Footstep_Gravel.play()
		$PlayerAudio/Timer.start(0.6)
	
	# Move and slide function uses velocity of character body to move character on map
	move_and_slide()
	pick_new_state()

func update_animation_parameters(move_input : Vector2):
	if(velocity != Vector2.ZERO):
		animation_tree.set("parameters/Walk/blend_position", move_input)
		animation_tree.set("parameters/Idle/blend_position", move_input)
		
func pick_new_state():
	if(velocity != Vector2.ZERO):
		state_machine.travel("Walk")
	else:
		state_machine.travel("Idle")
