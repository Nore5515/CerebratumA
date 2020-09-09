extends Node2D


var looper = 0
var maxLooper = 30

var looping = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	self.get_node("Label").text = String(Engine.get_frames_per_second())
	
	looping = true
	if Engine.get_frames_per_second() < 55 && !looping:
		looping = true
		maxLooper = Engine.get_frames_per_second()
		print ("LESS THAN 55! CURRENTLY AT ", String(Engine.get_frames_per_second()))
		var chillens = ""
		for child in get_tree().get_root().get_node("Testing").get_children():
			chillens += ("\t" + child.name)
			chillens += ("\n")
		print ("Current Children are:\n" + chillens)
	
	looping = false
	if looping:
		looper += 1
		if looper > maxLooper:
			looping = false
			looper = 0
