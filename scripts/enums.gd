extends Node
## Stores the different types of items
enum ITEM_TYPE { MAIN, HEAD, CHEST, LEGS, FEET, PRIMARY, SECONDARY, CAPE, AMMO, GLOVES, RING }

func convert_string_to_item_type(t: String) -> ITEM_TYPE:
	match t:
		"HEAD": return ITEM_TYPE.HEAD 
		"CHEST": return ITEM_TYPE.CHEST 
		"LEGS": return ITEM_TYPE.LEGS 
		"FEET": return ITEM_TYPE.FEET 
		"PRIMARY": return ITEM_TYPE.PRIMARY 
		"SECONDARY": return ITEM_TYPE.SECONDARY
		"CAPE": return ITEM_TYPE.CAPE 
		"AMMO": return ITEM_TYPE.AMMO 
		"GLOVES": return ITEM_TYPE.GLOVES 
		"RING": return ITEM_TYPE.RING
		_: return ITEM_TYPE.MAIN 
	

## Stores the different damage types
enum DAMAGE_TYPE { MELEE, RANGE, MAGIC }
func convert_string_to_damage_type(t: String) -> DAMAGE_TYPE:
	match t:
		"RANGE": return DAMAGE_TYPE.RANGE
		"MAGIC": return DAMAGE_TYPE.MAGIC
		_: return DAMAGE_TYPE.MELEE

## Define the different modes that we can use
enum MODE { DEV, TEST, PROD }

## Define directions that something is facing
enum DIRECTION_FACING { FRONT, RIGHT, LEFT, BACK }
