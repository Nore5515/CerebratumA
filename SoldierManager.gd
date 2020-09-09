extends Node2D


# The purpose of this script is to export/offload a LOT of the soldier stuff
# Specifically, to ensure that all soldier killing/shooting/movement is handled
# by ONE loop, not multiple. This will help optimization as well as
# prevent incidents where soldiers kill each other in the middle of a script.

# It will accomplish this by creating a list of all current soldiers, 
# Then moving them/handling deaths. Soldiers themselves can send fire
# requests upstream to this manager, but may not actually fire things themselves.
# NO PHYSICS PROCESS IN SOLDIERS AT ALL.


# The Soldier List
var soldiers = []

# Global
onready var global = get_node("/root/Global")

# Bullet Prefab
onready var bulletPrefab = load("res://Scenes/Bullet.tscn")

# Projectile Manager
onready var projManager = get_node("/root/ProjectileManager")

# Unit Manager
var unitManager



# To add soldiers to the manager.
func addSoldier(sol):
	soldiers.append(sol)
	
# To remove soldiers from the manager.
func removeSoldier(sol):
	soldiers.erase(sol)
	global.playDeath(sol.position)
	#sol.call_deferred("queue_free")
	sol.queue_free()
	
# To be called after a base gets destroyed!
func resetSoldierDests():
	for sol in soldiers:
		sol.refreshRivals()
		sol.setDest()

# Shoot a bullet from a soldier to a destination.
func fireAt(sol: Soldier, target: Vector2, sway : float):
	
	# If the soldier is clear to fire (aka fire delay ran out)
	# OR the soldier is being controlled, in which there is no delay
	if sol.clearToFire || sol.controlled:
		sol.clearToFire = false
		sol.get_node("FireDelay").start()
		var bulletInstance = bulletPrefab.instance()
		bulletInstance.set_name(sol.name + "'s bullet")
		bulletInstance.team = sol.team
		bulletInstance.modulate = sol.teamColor
		bulletInstance.position = sol.position
		projManager.addProj(bulletInstance)
		bulletInstance.look_at(target)
		global.playSound("Shoot")
		bulletInstance.call_deferred("rotate", sway)#rotate(sway)


# Updates the soldier's hostile units nearby list, by pruning it of non-existant hostiles.
# Updates the soldier's nearest hostile unit, from a list of all nearby hostiles.
func updateNear(sol: Soldier):
	
	var wr
	var nearest
	var near = []
	
	for obj in sol.near:
		wr = weakref(obj)
		if !wr.get_ref() || obj.team == sol.team:
			pass
		else:
			near.append(obj)
			if nearest == null:
				nearest = obj
			else:
				if nearest.position.distance_to(sol.position) < obj.position.distance_to(sol.position):
					nearest = obj

	if nearest != null:
		sol.nearest = nearest
		sol.near = near


func control(sol: Soldier):
	if !unitManager.controlling:
		sol.resetSprites = false
		sol.controlled = true
		sol.get_node("AngrySoldier").visible = true
		if !sol.dashing:
			sol.get_node("AbilityReady").visible = true
		unitManager.nowControlling(sol)

func _physics_process(delta):
	
	var direction
	var velo
	
	for sol in soldiers:
		# AI Movement
		if !sol.controlled:
			# Set the AI state to idle if there's no destination.
			if sol.dest == null:
				sol.idleState = true
			# Non-Idle moves towards their dest in straight line.
			if !sol.idleState:
				direction = (sol.dest - sol.position).normalized()
				velo = direction * sol.speed
				sol.move_and_slide(velo)
			# If they're idle, check for any possible destinations.
			else:
				sol.setDest()
		
		
		
		
		
		
		
		
		
		
		
		
		
	
	
