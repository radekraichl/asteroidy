extends Area2D

var contact_damage: int = 1000

func hit(hit_info: HitInfo):
	get_parent().hit(hit_info)
