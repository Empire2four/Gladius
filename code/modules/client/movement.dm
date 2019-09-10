
/client/New()
	..()
	dir = NORTH

/client/verb/spinleft()
	set name = "Поворот камеры на лево"
	set category = "OOC"
	dir = turn(dir, 90)

/client/verb/spinright()
	set name = "Поворот камеры на право"
	set category = "OOC"
	dir = turn(dir, -90)

