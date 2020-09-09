extends Node2D


onready var bg = self.get_node("bg")
onready var bg2 = self.get_node("bg2")
onready var resetPoint = self.get_node("ResetPoint")
onready var resetPoint2 = self.get_node("ResetPoint2")

var baseSpeed = 1
var boostSpeed = 5
var speed = baseSpeed

var viewing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	clear()


func clear():
	#get_node("Start").visible = false
	get_node("TeamPick").visible = false
	get_node("FreePick").visible = false
	#get_node("Info").visible = false
	get_node("InfoDeet").visible = false
	#get_node("Quit").visible = false


func _process(delta):
	bg.translate(transform.x * speed)
	bg2.translate(transform.x * speed)
	
	if bg.position.x > resetPoint.position.x:
		bg.position = resetPoint2.position
		print ("reset 1!")
	if bg2.position.x > resetPoint.position.x:
		bg2.position = resetPoint2.position
		print ("reset 2!")


func _input(event):
	
	if event.is_action_pressed("space"):
		speed = boostSpeed
	if event.is_action_released("space"):
		speed = baseSpeed


func _on_Start_pressed():
	clear()
	if !viewing:
		self.get_node("TeamPick").visible = true
		self.get_node("FreePick").visible = true
		viewing = true
	else:
		viewing = false


func _on_TeamPick_pressed():
	get_tree().change_scene("res://Scenes/Testing.tscn")
func _on_FreePick_pressed():
	get_tree().change_scene("res://Scenes/Testing.tscn")


func _on_Info_pressed():
	clear()
	if !viewing:
		self.get_node("InfoDeet").visible = true
		viewing = true
	else:
		viewing = false
