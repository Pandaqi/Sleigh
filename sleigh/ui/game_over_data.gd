extends GameOverData
class_name GameOverDataCustom

var game_over_good := false
var score : int = 0
var time_played : int = 0
var gifts_delivered : int = 0

func get_header() -> String:
	if game_over_good: return "GAME_OVER_HEADER_GOOD"
	return "GAME_OVER_HEADER_BAD"

func get_message() -> String:
	var msg := tr("GAME_OVER_MESSAGE_GOOD" if game_over_good else "GAME_OVER_MESSAGE_BAD")
	var stats := "{tr_1}: {time_played}\n{tr_2}: {gifts_delivered}\n{tr_3}: {score}".format({
		"tr_1": tr("TIME"),
		"time_played": time_played,
		"tr_2": tr("GIFTS"),
		"gifts_delivered": gifts_delivered,
		"tr_3": tr("SCORE"),
		"score": score
	})
	return msg + "\n"+ stats
