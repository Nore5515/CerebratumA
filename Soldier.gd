extends KinematicBody2D


export (bool) var controlled = false
var bullet = load("res://Bullet.tscn")

var speed = 500
var manager
var dest
var rng = RandomNumberGenerator.new()

var team
var homeBase
var enemyBase
var rivalList = []

var near = []
var nearest
var closest

var idleState = false


func _ready():
	rng.randomize()
	if dest == null:
		idleState = true

func prep(incManager):
	manager = incManager
	if rivalList.size() > 0:
		dest = rivalList[rng.randi_range(0,rivalList.size()-1)].position
		enemyBase = dest
		idleState = false
	else:
		idleState = true

func _on_SelectButton_pressed():
	controlled = true

	if manager == null:
		if get_tree().get_nodes_in_group("manager").size() != 0:
			#print (get_tree().get_nodes_in_group("manager"))
			manager = get_tree().get_nodes_in_group("manager")[0]
			manager.nowControlling(self)
			self.get_node("Select").play()
		else:
			self.get_node("Error").play()
	else:
		manager.nowControlling(self)
		self.get_node("Select").play()


func _physics_process(delta):
	
	if !controlled && !idleState:
		
		if dest == null:
			idleState = true
			
		else:
			var direction = (dest - self.position).normalized()
			var velocity = direction * speed
			move_and_slide(velocity)	
			#setDest()
			
	if idleState:
		setDest()
			

func setDest():
	
	if rivalList.size() <= 0:
		idleState = true
	
	elif near.size() > 0:
		nearest = null
		var distObj
		var distNear
		
		for obj in near:
			if obj.is_in_group("unit") && nearest == null && obj.team != team:
				nearest = obj
			elif obj.is_in_group("unit") && nearest != null && obj.team != team:
				distObj = obj.position.distance_to(self.position)
				distNear = nearest.position.distance_to(self.position)
				if distObj < distNear:
					nearest = obj
		
		if nearest == null:
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
	var wr
	for rival in rivalList:
		wr = weakref(rival)
		if wr.get_ref():
			print (rival.name, rival.team, rival, self.name, self.team, self, obj.name, obj.team, obj)
			if rival.team == obj.team:
				return true
	return false


func kill():
	var wr = weakref(homeBase)
	if wr.get_ref():
		homeBase.soldierDown(self)
	else:
		call_deferred("queue_free")

func shootAt(target):
	if target == null:
		print ("WAHT ")
	var boolet = bullet.instance()
	boolet.set_name("Boolet")
	boolet.team = team
	#self.get_parent().add_child(boolet)
	get_parent().call_deferred("add_child", boolet)
	boolet.call_deferred("set_position", position)
	boolet.call_deferred("look_at", target.position)
	#boolet.look_at(target.position)
	#boolet.position = position
	#print ("CHECK FOR BUGS: ", target.name)
	#print (target.name)
	#var angle = boolet.position.angle_to_point(target.position)
	#boolet.rotation = -angle + (PI * 1.5)


func _on_ShootRadius_body_entered(body):
	if body.is_in_group("unit"):
		if checkTeam(body):
			shootAt(body)

