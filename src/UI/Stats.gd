extends Panel


onready var time_date_label = $TimeDate


# Called when the node enters the scene tree for the first time.
func _ready():
	var time_date = Get_date_day()
	time_date_label.text = str(time_date.Day, "|", time_date.Date, "|", time_date.Time)


func _on_Timer_timeout():
	# only update per second
	var time_date = Get_date_day()
	time_date_label.text = str(time_date.Day, "|", time_date.Date, "|", time_date.Time)


func Get_date_day():
	var date = ""
	var prefix = ""
	var curr_week = ""
	if OS.get_datetime().day == 1 or OS.get_datetime().day == 21  or OS.get_datetime().day == 31:
		prefix = "st  of "
	elif OS.get_datetime().day == 2 or OS.get_datetime().day == 22:
		prefix = "nd  of "
	elif OS.get_datetime().day == 3 or OS.get_datetime().day == 23:
		prefix = "rd  of "
	else:
		prefix = "th  of "
	
	if OS.get_datetime().weekday == 1:
		curr_week = "Monday"
	elif OS.get_datetime().weekday == 2:
		curr_week = "Tuesday"
	elif OS.get_datetime().weekday == 3:
		curr_week = "Wednesday"
	elif OS.get_datetime().weekday == 4:
		curr_week = "Thursday"
	elif OS.get_datetime().weekday == 5:
		curr_week = "Friday"
	elif OS.get_datetime().weekday == 6:
		curr_week = "Saturday"
	else:
		curr_week = "Sunday"
	
	
	if OS.get_datetime().month == 1:
		date = "January"
	elif OS.get_datetime().month == 2:
		date = "Feburary"
	elif OS.get_datetime().month == 3:
		date = "March"
	elif OS.get_datetime().month == 4:
		date = "April"
	elif OS.get_datetime().month == 5:
		date = "May"
	elif OS.get_datetime().month == 6:
		date = "June"
	elif OS.get_datetime().month == 7:
		date = "July"
	elif OS.get_datetime().month == 8:
		date = "August"
	elif OS.get_datetime().month == 9:
		date = "September"
	elif OS.get_datetime().month == 10:
		date = "Octuber"
	elif OS.get_datetime().month == 11:
		date = "November"
	else:
		date = "December"
	
	var info = { "Date" : str(OS.get_datetime().day, prefix , date , "," , OS.get_datetime().year),
				 "Day": str(curr_week),
				"Time": str(OS.get_time().hour, ":", OS.get_time().minute, ":", OS.get_time().second)
				}
	return info

