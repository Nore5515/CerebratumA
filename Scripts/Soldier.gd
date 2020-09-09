extends KinematicBody2D


class_name Soldier

export (bool) var controlled = false
export (int) var inaccuracyDegrees = 30
var bullet = load("res://Scenes/Bullet.tscn")
onready var global = get_node("/root/Global")
onready var projManager = get_node("/root/ProjectileManager")
onready var solManager = get_node("/root/SoldierManager")

var speed = 350
var baseSpeed = 350
var dashSpeed = 700
var manager
var dest
var rng = RandomNumberGenerator.new()

var team
var teamColor
var homeBase
var enemyBase
var rivalList = []

var near = []
var fightingRange = []
var nearest
var closest

# State Flags
var idleState = false
var firing = false
var fighting = false
var dead = false
var dashing = false
var clearToFire = false
var resetSprites = false

func _ready():
	rng.randomize()
	if dest == null:
		idleState = true
	print (rivalList)

func prep(incManager):
	manager = incManager
	if rivalList.size() > 0:
		dest = rivalList[rng.randi_range(0,rivalList.size()-1)].position
		enemyBase = dest
		idleState = false
	else:
		idleState = true


func setColor(color):
	teamColor = color
	
	for child in get_children():
		if child.is_in_group("sprite"):
			child.modulate = teamColor


func _input(event):
	if event.is_action_pressed("lClick"):
		var size = self.get_node("Soldier").texture.get_size()
		var upperLeft = Vector2(\
			global_position.x - (size.x * 0.5),\
			global_position.y - (size.y * 0.5))
		var rect = Rect2(upperLeft, size)
		if rect.has_point(get_global_mouse_position()):
			print (name, " HAS BEEN CHOSEN")
			solManager.control(self)


func _physics_process(delta):
	
	# Ensures the sprites go away once you stop controlling.
	if !controlled && !resetSprites:
		if self.get_node("AngrySoldier").visible:
			self.get_node("AngrySoldier").visible = false
		if self.get_node("RagingAngrySoldier").visible:
			self.get_node("RagingAngrySoldier").visible = false
		if self.get_node("AbilityReady").visible:
			self.get_node("AbilityReady").visible = false
		resetSprites = true
			

func refreshRivals():
	rivalList = []
	for b in get_tree().get_nodes_in_group("base"):
		if b.team != team:
			rivalList.append(b)
	if rivalList.size() <= 0:
		print("GAME OVER")

func setDest():
	
	if rivalList.size() <= 0:
		idleState = true
	
	elif near.size() > 0:
		nearest = null
		
		refreshNear()
		
		if nearest == null:
			#print ("There's no nearby enemies!")
			var pick = rng.randi_range(0,rivalList.size()-1)
			dest = rivalList[pick].position
			idleState = false

		else:
			dest = nearest.position	
			idleState = false
	
	else:
		pass
		#print ("Carrying on...")


func _on_Vision_body_entered(body):
	if !idleState:
		if body.is_in_group("unit"):
			near.append(body)
	# shoot at body pew pew


func _on_Vision_body_exited(body):
	if !idleState:
		if near.has(body):
			near.erase(body)


func checkTeam(obj):
	if obj.team != team:
		return true
	return false
	


func kill():
	dead = true
	var wr = weakref(homeBase)
	manager.freeControl(self)
	if wr.get_ref():
		homeBase.soldierDown(self)
	else:
		pass#print ("Something went wrong in kill!")
	solManager.removeSoldier(self)


func shootAt(target, sway):
	#print (name, near[0].name)
	solManager.fireAt(self,target,rng.randf_range(-sway, sway))
	
		
func altFire(mousePos):
	
	if !dashing:
		speed = dashSpeed
		self.get_node("DashTime").start()
		dashing = true
		self.get_node("RagingAngrySoldier").visible = true
		self.get_node("AbilityReady").visible = false


func _on_ShootRadius_body_entered(body):
	if body.is_in_group("unit") && !controlled && checkTeam(body):
		self.get_node("FireDelay").start()


func refreshNear():
	solManager.updateNear(self)



func _on_FireDelay_timeout():
	clearToFire = true
	if near.size() > 0:
		refreshNear()
		if nearest != null:
			var wr = weakref(nearest)
			if wr.get_ref():
				shootAt(nearest.position, deg2rad(inaccuracyDegrees))


# DASHING STUFF
func _on_DashTime_timeout():
	self.get_node("RagingAngrySoldier").visible = false
	self.get_node("DashCooldown").start()
	speed = baseSpeed
func _on_DashCooldown_timeout():
	self.get_node("AbilityReady").visible = true
	dashing = false
