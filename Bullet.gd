extends KinematicBody2D


var speed = 1000
var team
var lifetime = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	self.get_node("BulletLife").wait_time = 3
	self.get_node("BulletLife").start()



func _physics_process(delta):
	move_and_slide(transform.x * speed)


func _on_Hitbox_body_entered(body):
	if body.is_in_group("unit"):
		if body.team != team:
			body.kill()
			body.call_deferred("queue_free")
			self.call_deferred("queue_free")
			
	if body.is_in_group("base"):
		if body.team != team:
			body.baseDown()
			#body.manager.baseDown(body)
			self.call_deferred("queue_free")


func _on_BulletLife_timeout():
	self.call_deferred("queue_free")
