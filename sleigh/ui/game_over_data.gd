extends GameOverData

@export var map_data : MapData

func get_header() -> String:
	if map_data.game_over_good: return "GAME_OVER_HEADING_GOOD"
	return "GAME_OVER_HEADING_BAD"

func get_message() -> String:
	var msg := tr("GAME_OVER_MESSAGE_GOOD" if map_data.game_over_good else "GAME_OVER_MESSAGE_BAD")
	var stats := "{tr_1}: {time_played}\n{tr_2}: {gifts_delivered}\n{tr_3}: {score}".format({
		"tr_1": tr("TIME"),
		"time_played": map_data.time_played,
		"tr_2": tr("GIFTS"),
		"gifts_delivered": map_data,
		"tr_3": tr("SCORE"),
		"score": map_data.score
	})
	return msg + "\n"+ stats
