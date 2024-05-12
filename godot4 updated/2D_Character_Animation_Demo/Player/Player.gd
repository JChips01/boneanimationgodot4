extends CharacterBody2D
class_name Player

var x_input: float = 0.0
var pause_lock: bool = false

@onready var sprite = $PlayerSprite
@onready var f_arm = $PlayerSprite/Torso/R_Arm
@onready var b_arm = $PlayerSprite/Torso/L_Arm
@onready var hand = $PlayerSprite/Torso/R_Arm/Hand
@onready var aim_pivot = $PlayerSprite/Torso/AimPivot
@onready var fsm = $FSM
@onready var leg_anim = $LegsAnimation

@export var MAX_SPEED		: int = 18
@export var ACCELERATION	: int = 100
@export var FRICTION		: float = 1.0

@export var base_hp			: int = 0
@onready var hp: int = base_hp

var motion : Vector2 = Vector2.ZERO

signal health_updated()
signal health_depleted()
signal got_hurt()

func _idle():
	motion.x = lerp(motion.x, 0.0, FRICTION)

func _move(delta, direction):
	motion.x += direction * ACCELERATION * delta
	motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
	velocity = motion
	up_direction = Vector2.UP
	move_and_slide()

func hurt(damage: int):
	_set_health(self.hp - damage)
	emit_signal("got_hurt")

func _set_health(new_val: int):
	self.hp = new_val
	emit_signal("health_updated")
	if self.hp <= 0:
		emit_signal("health_depleted")

func apply_physics():
	velocity = motion
	up_direction = Vector2.UP
	move_and_slide()

func _player_input():
	x_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")


func aim(pos: Vector2):
	_flip_player_sprite(pos.x < self.global_position.x)
	if (pos.x < self.global_position.x):
		f_arm.rotation = lerp_angle(f_arm.rotation, -(aim_pivot.global_position - pos).angle(), (0.10))
	else:
		f_arm.rotation = lerp_angle(f_arm.rotation, (pos - aim_pivot.global_position).angle(), (0.10))
	b_arm.look_at(hand.global_position)


func _flip_player_sprite(flip: bool):
	match flip:
		true:
			sprite.scale.x = -1
		false:
			sprite.scale.x = 1


func _animate_legs():
	if (x_input == 0):
		leg_anim.play("Idle")
	else:
		var is_forward: bool = (
				(sprite.scale.x == 1 and x_input > 0)
				or (sprite.scale == Vector2(-1,1) and x_input < 0)
		)
		
		match is_forward:
			true:
				leg_anim.play("Walk_Forward")
			false:
				leg_anim.play("Walk_Backward")
