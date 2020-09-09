extends KinematicBody2D


export (String) var team
export (Color) var teamColor
var manager
var rivals
var units = []

export (int) var maxHP = 100
var hp = maxHP
var regen = 1

var soldierPrefab = load("res://Scenes/Soldier.tscn")
onready var spawnTimer = self.get_node("SpawnTimer")

onready var solManager = get_node("/root/SoldierManager")

# Called when the node enters the scene tree for the first time.
func _ready():
	spawnTimer.start()
	self.modulate = teamColor
	self.get_node("HPbar").max_value = maxHP
	self.get_node("HPbar").value = maxHP

func soldierDown(deadGuy):
	if units.has(deadGuy):
		units.erase(deadGuy)


func baseDown():
	for u in units:
		solManager.removeSoldier(u)
		#u.call_deferred("queue_free")
	solManager.resetSoldierDests()
	call_deferred("queue_free")


func hurt(dmg):
	hp -= dmg
	self.get_node("HPbar").value = hp
	if hp <= 0:
		baseDown()


func spawnSolder():
	var obj = soldierPrefab.instance()
	obj.position = position
	obj.set_name(team + " Soldier")
	obj.team = team
	obj.setColor(teamColor)
	obj.homeBase = self
	solManager.addSoldier(obj)
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
		#print (u.name)
		u.rivalList = rivals


func heal(val):
	if hp < maxHP:
		if (hp + val) >= maxHP:
			hp = maxHP
		else:
			hp += val


func _on_HealTimer_timeout():
	if hp < maxHP:
		heal(regen)
