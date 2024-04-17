extends Node

var HasDubbleJump = true
var BoostCount = 9999930.0 : set = setBoostCount

func setBoostCount(val):
	BoostCount = max(0, val)
