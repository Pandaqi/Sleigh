class_name GridCell

enum ContentType
{
	NONE,
	BUILDING,
	GIFT
}

var pos : Vector2i
var possible_contents : Dictionary[ContentType,bool] = {}
var content := ContentType.NONE
var building := -1
var height := 0.0

func _init(p:Vector2i) -> void:
	pos = p

func print_pretty() -> String:
	if content == ContentType.BUILDING: return "B"
	if content == ContentType.GIFT: return "G"
	return " "

func set_possible_contents(pc:Dictionary[ContentType, bool]) -> void:
	possible_contents = pc

func accepts_content(tp:ContentType) -> bool:
	if has_content(): return false
	return possible_contents[tp] == true

func has_content() -> bool:
	return content != ContentType.NONE

func set_content(tp:ContentType) -> void:
	content = tp

func forbid_content(tp:ContentType) -> void:
	possible_contents[tp] = false

func allow_content(tp:ContentType) -> void:
	possible_contents[tp] = true

func set_building(idx:int) -> void:
	building = idx

func set_height(h:float) -> void:
	height = h
