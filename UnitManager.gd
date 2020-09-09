extends Node2D


var units = []
var rivals
var controlledUnit

var soldierPrefab = load("res://Soldier.tscn")
onready var camera = self.get_node("Camera2D")

var camSpeed = 15
var originalZoom

var controlling = false
var spawning = true

var left
var right
var up
var down
var shooting


onready var bases = get_tree().get_nodes_in_group("base")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	originalZoom = camera.zoom
	
	assignRivals()

func assignRivals():
	bases = get_tree().get_nodes_in_group("base")
	
	for base in bases:
		base.manager = self
		rivals = []
		for b in bases:
			if b != base:
				rivals.append(b)
		base.rivals = rivals
	

func baseDown(deadBase):
	bases = get_tree().get_nodes_in_group("base")
	
	for base in bases:
		base.manager = self
		rivals = []
		if base != deadBase:
			for b in bases:
				if b != base && base != deadBase:
					rivals.append(b)
			base.rivals = rivals
			base.updateUnits()
	
	deadBase.call_deferred("queue_free")

func _process(delta):
	
	if controlling && weakref(controlledUnit).get_ref():
		if !controlledUnit.is_in_group("unit"):
			controlledUnit = null
			controlling = false
		else:
			camera.set_position(controlledUnit.get_position())
			if left:
				controlledUnit.move_and_slide(Vector2(-controlledUnit.speed,0))
			if right:
				controlledUnit.move_and_slide(Vector2(controlledUnit.speed,0))
			if up:
				controlledUnit.move_and_slide(Vector2(0,-controlledUnit.speed))
			if down:
				controlledUnit.move_and_slide(Vector2(0,controlledUnit.speed))
			if shooting:
				controlledUnit.shootAt(get_global_mouse_position(), deg2rad(0))
				shooting = false

	if !controlling:
		
		if left:
			camera.translate(Vector2(-camSpeed,0))
		if right:
			camera.translate(Vector2(camSpeed,0))
		if up:
			camera.translate(Vector2(0,-camSpeed))
		if down:
			camera.translate(Vector2(0,camSpeed))

func _on_tempButton_pressed():
	
	if spawning:
		var obj = soldierPrefab.instance()
		obj.rivalTeams = rivals
		obj.set_name("Unit")
		add_child(obj)
		obj.prep(self)
		obj.set_position(Vector2(0,0))
	
func nowControlling(controlled):
	#print (controlled)
	controlledUnit = controlled
	controlling = true
	spawning = false
	self.get_node("Camera2D").position = controlledUnit.position
	
func freeControl(toBeReleased):
	if toBeReleased == controlledUnit:
		controlledUnit = null
		controlling = false
	
func _input(event):
	
	if event.is_action_pressed("left"):
		left = true
	if event.is_action_pressed("right"):
		right = true
	if event.is_action_pressed("up"):
		up = true
	if event.is_action_pressed("down"):
		down = true
	
	if event.is_action_released("left"):
		left = false
	if event.is_action_released("right"):
		right = false
	if event.is_action_released("up"):
		up = false
	if event.is_action_released("down"):
		down = false

	if event.is_action_pressed("scrollUp"):
		camera.zoom *= 0.9
	if event.is_action_pressed("scrollDown"):
		camera.zoom *= 1.1
	
	if event.is_action_pressed("esc"):
		controlling = false
		controlledUnit.controlled = false
		spawning = true
		self.get_node("Deselect").play()
		
	if event.is_action_pressed("z"):
		camera.zoom = originalZoom
		
	if event.is_action_pressed("fire"):
		shooting = true
		
