function love.load()
	io.stdout:setvbuf("no")
	map = {}

	MAP_SIZE_X = 64 
	MAP_SIZE_Y = 64 
	CELL_SIZE = 8

	CHANCE_NEWWALKER = 0.2
	CHANCE_DESTROWALKER = 0.05
	CHANCE_CHANGEDIR = 0.5
	MAX_WALKER = 20
	MAX_HOLES = (MAP_SIZE_X * MAP_SIZE_Y) / 2

	walkers = {}
	generationDone = false
	nHoles = 0 

	timerMapGen = 0

	resetMap()
	initMapGen()
	updateMapGen()
end

function love.update(dt)
	timerMapGen = timerMapGen + dt
	if timerMapGen >= 0.005 then
		timerMapGen = 0
		if generationDone == false then updateMapGen() 
		else endOfGeneration() end
	end
end


function love.draw()
	drawMap()
	love.graphics.print(nHoles, 8, 8)
	love.graphics.print(MAX_HOLES, 8, 24)
end

function love.keypressed(key, unicode)
	if key == "space" then
		resetMap()
		initMapGen()
		updateMapGen()
	end
end

function resetMap() 
	for i=1, MAP_SIZE_X do
		map[i] = {}
		for j=1, MAP_SIZE_Y do
			map[i][j] = 1
		end
	end
	nHoles = 0
end

function initMapGen()
	math.randomseed(os.time())
	walkers = {}
	generationDone = false
	table.insert(walkers, {x = math.random(2,MAP_SIZE_X - 1), y = math.random(2,MAP_SIZE_Y - 1), dir = math.random(1,4)})
end

function updateMapGen()
	-- DIRS
	-- 1 : N
	-- 2 : E
	-- 3 : S
	-- 4 : W

	if nHoles >= MAX_HOLES then
		-- end of generation
		print("done")
		walkers = {}
		generationDone = true
	else
		--proceed generation
		for i,v in pairs(walkers) do
			-- if reached edge of map, go back opposite dir
			if v.x == 2 and v.dir == 4 then
				v.dir = 2
				v.x = v.x + 1
			elseif v.x == MAP_SIZE_X - 1 and v.dir == 2 then
				v.dir = 4
				v.x = v.x - 1
			elseif v.y == 2 and v.dir == 1 then
				v.dir = 3
				v.y = v.y + 1
			elseif v.y == MAP_SIZE_Y - 1 and v.dir == 3 then
				v.dir = 1
				v.y = v.y - 1
			else
				-- normal walk behavior
				if v.dir == 1 then
					v.y = v.y - 1
				elseif v.dir == 2 then
					v.x = v.x + 1
				elseif v.dir == 3 then
					v.y = v.y + 1
				elseif v.dir == 4 then
					v.x = v.x - 1
				end
			end
			-- dig hole
			if map[v.x][v.y] == 1 then
				map[v.x][v.y] = 0
				nHoles = nHoles + 1
			end
			-- can change dir
			if math.random() <= CHANCE_CHANGEDIR then
				v.dir = math.random(1,4)
			end

			-- can create new walker
			if math.random() <= CHANCE_NEWWALKER and #walkers <= MAX_WALKER then
				table.insert(walkers, {x = v.x, y = v.y, dir = math.random(1,4)})
			end

			-- can die
			if math.random() <= CHANCE_DESTROWALKER and #walkers > 1 then
				table.remove(walkers, i)
			end
		end
	end
end

function drawMap()
	for i=1, MAP_SIZE_X do
		for j=1, MAP_SIZE_Y do
			if map[i][j] == 1 then
				love.graphics.setColor(255, 255, 255)
				love.graphics.rectangle("fill",i*CELL_SIZE,j*CELL_SIZE,CELL_SIZE,CELL_SIZE)
			end
		end
	end
	for _,v in pairs(walkers) do
		love.graphics.setColor(255, 0, 0)
		love.graphics.rectangle("fill",v.x*CELL_SIZE,v.y*CELL_SIZE,CELL_SIZE,CELL_SIZE)
	end
end


function endOfGeneration() 
	resultMap = {}

	for i=1, MAP_SIZE_X do
		for j=1, MAP_SIZE_Y do
			table.insert(resultMap, map[i][j])
		end
	end

	return resultMap
end