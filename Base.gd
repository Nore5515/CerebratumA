extends KinematicBody2D


export (String) var team
export (Color) var teamColor
var manager
var rivals
var units = []

export (int) var maxHP = 100
var hp = maxHP

var soldierPrefab = load("res://Soldier.tscn")
onready var spawnTimer = self.get_node("SpawnTimer")

# Called when the node enters the scene tree for the first time.
func _ready():
	spawnTimer.start()
	self.modulate = teamColor


func soldierDown(deadGuy):
	if units.has(deadGuy):
		units.erase(deadGuy)


func baseDown():
	for u in units:
		u.call_deferred("queue_free")
	call_deferred("queue_free")

func spawnSolder():
	var obj = soldierPrefab.instance()
	obj.position = position
	obj.set_name(team + " Soldier")
	obj.team = team
	obj.modulate = teamColor
	obj.homeBase = self
	units.append(obj)
	return obj

func _on_SpawnTimer_timeout():
	manager.assignRivals()
	
	var man = spawnSolder()
	self.get_parent().add_child(man)
	#man.position = self.global_position
	
	man.rivalList = rivals
	man.prep(manager)
	
	spawnTimer.start()

func updateUnits():
	for u in units:
		print (u.name)
		u.rivalList = rivals
