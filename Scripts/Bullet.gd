extends Area2D


var speed = 1000
var team
var lifetime = 1.5
var dmg = 1

onready var projManager = get_node("/root/ProjectileManager")

# Called when the node enters the scene tree for the first time.
func _ready():
	self.get_node("BulletLife").wait_time = lifetime
	self.get_node("BulletLife").start()

func sway(angle):
	rotate(angle)

func _on_Bullet_body_entered(body):
	if body.is_in_group("unit"):
		if body.team != team:
			body.kill()
			destroySelf()
			
	if body.is_in_group("base"):
		if body.team != team:
			body.hurt(dmg)
			destroySelf()
			
	if body.name == "Tilemap":
		destroySelf()


func _on_BulletLife_timeout():
	destroySelf()
	

func destroySelf():
	projManager.removeProj(self)
	#self.call_deferred("queue_free")
