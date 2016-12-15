
-- WARNING PHASE
-- lasts 60 seconds
-- loudspeakers announce incoming ship
-- at 20 seconds incoming lasers start firing
-- at 25 seconds alarms blare
-- at 30 seconds outgoing lasers fire

-- RAIDER SPAWNING PHASE
-- raider spawning lasts 60 seconds
-- spawn raiders at questlocations every 20 seconds
-- number of raiders per spawn = threat level/2 + 1 (rounded up)

function init()
--  if not entity.uniqueId() then
--    stagehand.setUniqueId(sb.makeUuid())
--  end
  
--  local eventType = config.getParameter("eventType")
  self.raiderspawnperiods = { [1] = 40, [2] = 30, [3] = 30, [4] = 20, [5] = 20, [6] = 20, [7] = 15}
  if not storage.starttime then
	sb.logInfo("starting timers. Start Time: "..os.time())
	storage.starttime = os.time()
	storage.stage = 1
  end
  sb.logInfo("event started at "..storage.starttime..". Ends at"..storage.starttime+440)
  if not storage.spawnpoints then
  	storage.spawnpoints = spawnLocations()
  end
  
  if not storage.hostiles then
	storage.hostiles = {}
  end
  -- if this event was abandoned, do stuff and die
	if os.time() >= (storage.starttime + 440) then
--		sb.logInfo("This is an old event")
		endEvent()
	end
  message.setHandler("endEvent", function(_, _) 
	endEvent()
  end)
end

function update(dt)
	self.timer = os.time() - storage.starttime
	if storage.stage == 1 then
	-- WARNING PHASE
--	sb.logInfo("Warning Phase")
--	sb.logInfo("Time elapsed: "..self.timer..", Time: "..os.time())
		if not self.announced then
			broadcast("Attention! We have an unidentified incoming vessel.")
			self.announced = 1
		end
		if self.timer > 30 and storage.lasers ~= true then
			lasers(true)
			storage.lasers = true
		end
		if self.timer > 20 and storage.enemylasers ~= true then
			enemylasers(true)
			storage.enemylasers = true
		end
		if self.timer > 25 and self.announced < 2 then
			broadcast("We're taking incoming fire! All personel to battle stations!")
			self.announced = 2
			alarms(true)
		end
		if self.timer == 30 then
			lasers(true)
		end
		if self.timer > 50 and self.announced < 3 then
			broadcast("Prepare for boarders!")
			self.announced = 3
		end
		if self.timer >= 60 then
			storage.stage = 2
		end
	elseif storage.stage == 2 then
		-- spawn raiders every x seconds
		-- determined by station threat level
		local spawnperiod = self.raiderspawnperiods[world.threatLevel()]
		if self.timer % spawnperiod == 0 and storage.lastSpawn ~= os.time() then
			broadcast("Raiders teleporting in")
			storage.lastSpawn = os.time()
			spawnRaiders()
		end
		if self.timer >= 120 then
			storage.stage = 3
		end
	elseif storage.stage >= 3 then
		broadcast("The raiders' ship is leaving, time to mop up")
		lasers(false)
		enemylasers(false)
		alarms(false)
		stagehand.die()
	end
end

function spawnLocations()
	local spawnpoints ={}
	local stagehands = world.entityQuery(entity.position(), 200, { includedTypes = {"stagehand"}})
	for _,entityId in pairs(stagehands) do
		if world.stagehandType(entityId) == "questlocation" or world.stagehandType(entityId) == "stationlocation" then
--			sb.logInfo("spawnpoint found: ")
			location = world.entityPosition(entityId)
			table.insert(spawnpoints,location)
		end
	end
	return spawnpoints or nil
end

function stationmaster()
	stagehands = world.entityQuery(entity.position(), 20, { includedTypes = {"stagehand"} })
	local stationmaster = nil
	for _,entityId in ipairs(stagehands) do
		if world.stagehandType(entityId) == "stationmanager" then
			stationmaster = entityId
		end
	end
	if not stationmaster then
		sb.logInfo("The stationmaster is dead")
		stagehand.die()
	end
	return stationmaster
end

function spawnRaidersAtLoc(numRaiders, location)
--	sb.logInfo("Spawning raiders")
	local raider = config.getParameter("raider")
	for i=1, numRaiders do
		wiggle = {3-math.random(5),3-math.random(5)}
		loc = {location[1]+wiggle[1],location[2]+wiggle[2]}
		local raiderlevel = math.max(world.threatLevel()-1, 1)
		local hostile = world.spawnNpc(loc, raider[1], raider[2], raiderlevel)
		hostileUID = sb.makeUuid()
		world.setUniqueId(hostile, hostileUID)
		table.insert(storage.hostiles, hostileUID)
	end
end

function spawnRaiders()
	local numRaiders = math.ceil(world.threatLevel()/2) + 1
--	sb.logInfo("raiders per spawn: "..numRaiders)
	
	storage.spawnpoints = spawnLocations()
		
-- if the station threatlevel is 3 or lower, only spawn raiders at one location for each player present. Choose the locations closest to players
	if world.threatLevel() <= 3 then
		local localPlayers = world.playerQuery(entity.position(), 200)
		sb.logInfo("There are this many players on the station: " .. #localPlayers)
		if #storage.spawnpoints > #localPlayers then
			local shortenedLocations = {}
			for _,player in ipairs(localPlayers) do
				local closestLocation = nil
				local currentDist = 9000
				local playerPos = world.entityPosition(player)
				for key,location in pairs(storage.spawnpoints) do
					if world.magnitude(playerPos, location) < currentDist then
						closestLocation = location
						keyLoc = key
						currentDist = world.magnitude(playerPos, location)
					end
				end 
				table.insert(shortenedLocations,closestLocation)
				table.remove(storage.spawnpoints,keyLoc)
			end
			storage.spawnpoints = shortenedLocations
		end
	end
	
	for _,location in ipairs(storage.spawnpoints) do
		spawnRaidersAtLoc(numRaiders, location)
	end
end

function broadcast(msg)
	world.sendEntityMessage(stationmaster(), "broadcast", msg)
end

function startTimers()
end

function lasers(toggle)
	world.sendEntityMessage(stationmaster(), "stationlasers", toggle)
end

function enemylasers(toggle)
	world.sendEntityMessage(stationmaster(), "enemylasers", toggle)
end

function alarms(toggle)
	world.sendEntityMessage(stationmaster(), "alarms", toggle)
end

function clearRaiders()
	if storage.hostiles == nil then
		return nil
	end
	for _,raider in ipairs(storage.hostiles) do
      local entityId = world.loadUniqueEntity(raider)
      if entityId ~= 0 then
		world.sendEntityMessage(raider, "tenant.evictTenant")
      end
	end
end

function endEvent()
	sb.logInfo("Clearing old event")
	lasers(false)
	alarms(false)
	clearRaiders()
	stagehand.die()
end