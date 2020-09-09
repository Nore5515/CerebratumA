extends Node2D


# The purpose of this scene is to manage and handle ALL bullets.
# This will set internal timers for each bullet, and destroy them when that timer is up.
# Whenever a bullet is instaniated, it will be added to a list here.
# All bullets will be moved from here as well.
# No bullet should have ANYTHING going on in physics process.

# The bullets.
var bullets = []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Adding new projectiles to the manager
func addProj(proj):
	bullets.append(proj)
	get_tree().get_root().add_child(proj)


# Removing projectiles from the manager
func removeProj(proj):
	bullets.erase(proj)
	proj.call_deferred("queue_free")


# Moving all bullets
func _physics_process(delta):
	var wr
	for bullet in bullets:
		wr = weakref(bullet)
		if wr.get_ref():
			#bullet.move_and_slide(bullet.transform.x * bullet.speed)
			#bullet.position = Vector2(bullet.position.x + bullet.speed * delta, bullet.position.y)
			var move = bullet.transform.x
			move = move * bullet.speed
			bullet.position += move * delta
