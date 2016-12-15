require("/scripts/util.lua")
require("/scripts/vec2.lua")

stages = {"arriving", "idle", "departing", "empty"}
dockingTime = 20

function init()
	rotationTime = config.getParameter("visitTime")
	storage.currentState = "idle"
	animator.resetTransformationGroup("shiptransform")
	storage.dock = nearestDock()
	if storage.crew == nil then
		storage.crew = {}
	end
	if storage.currentship == nil or storage.shipDepart == nil or storage.shipDepart < os.time() then
		recallAllCrewmembers()
		local newship = selectShip()
		storage.currentship = newship
		setDeparture()
		storage.dock = nearestDock()
		if storage.dock ~= nil then
			spawnAllCrew()
		end
	end
	displayShip(storage.currentship.shipType)
	sb.logInfo("ship in: "..storage.currentship.shipType)
	self.crewIDs = {}
end

function update(dt)
	rotationTime = config.getParameter("visitTime")
	if storage.currentState == "idle" then
		animator.resetTransformationGroup("shiptransform")
		if #storage.crew < 1 and storage.currentship ~= "none" then
			spawnAllCrew()
		end
		if os.time() >= storage.shipDepart then
			recallAllCrewmembers()
			departShip()
		end
	elseif storage.currentState == "arriving" then
		local percentTrans = (os.time() - storage.dockingStart)/dockingTime
		animator.translateTransformationGroup("shiptransform", {.2, 0})
		if os.time() >= (storage.dockingStart + dockingTime) then
			storage.currentState = "idle"
			spawnAllCrew()
		end
	elseif storage.currentState == "departing" then
		local percentTrans = 1 - (os.time() - storage.dockingStart)/dockingTime
		animator.translateTransformationGroup("shiptransform", {-.2, 0})
		if os.time() >= storage.dockingStart + dockingTime then
			storage.currentState = "empty"
		end
	elseif storage.currentState == "empty" then
		storage.currentship = selectShip()
		arriveShip(storage.currentship.shipType)
	else
		storage.currentState = "idle"
	end
end

function displayShip(shipname)
	animator.setGlobalTag("ship", shipname)
	sb.logInfo("Set ship to "..shipname)
end

function setDeparture()
	storage.shipDepart = os.time() + rotationTime
	sb.logInfo("Ship Departs at: "..storage.shipDepart)
	return storage.shipDepart
end

function selectShip()
	local ships = config.getParameter("shipTypes")
	local ship = util.randomFromList(ships)
	return ship
end

function arriveShip(shipName)
	sb.logInfo("Arriving new ship: "..shipName)
	displayShip(shipName)
	if storage.currentship.shipType ~= "none" then
		animator.playSound("arrive")
	end
	setDeparture()
	storage.currentState = "arriving"
	storage.dockingStart = os.time()
	return true
end

function departShip()
	sb.logInfo("Departing old ship: "..storage.currentship.shipType)
	if storage.currentship.shipType ~= "none" then
		animator.playSound("depart")
	end
	storage.shipDepart = nil
	storage.currentState = "departing"
	storage.dockingStart = os.time()
	return true
end

function nearestDock()
	local stagehands = world.entityQuery(entity.position(), 200, { includedTypes = {"stagehand"}, order = "nearest" })
	for _,entityId in pairs(stagehands) do
		if world.stagehandType(entityId) == "questlocation" or world.stagehandType(entityId) == "stationlocation" then
			location = world.entityPosition(entityId)
			sb.logInfo(util.tableToString(location))
			dock = {location[1]-4,location[2]-4,location[1]+4,location[2]+4}
			util.debugRect(dock, "green")
			world.debugText("Dock",location,"green")
		end
	end
	return dock or nil
end

function spawnAllCrew()
	storage.dock = nearestDock()
	if storage.dock == nil then
		sb.logError("No Dock Availible")
		return false
	end
	if storage.currentship.crew == nil then
		sb.logError("No Ship Availible")
		return false
	end
	storage.crew = {}
	sb.logInfo("spawning in dock at "..util.tableToString(storage.dock))
	for _,crewperson in ipairs(storage.currentship.crew) do
		local randLocate = {}
		randLocate[1] = util.randomIntInRange({dock[1],dock[3]})
		randLocate[2] = util.randomIntInRange({dock[2],dock[4]})
		sb.logInfo("random location is at "..util.tableToString(randLocate))
		spawnCrewmember(crewperson[1], crewperson[2], randLocate)
	end
end

function spawnCrewmember(species, npcType, location)
	sb.logInfo("spawning at "..util.tableToString(location))
	newCrew = world.spawnNpc(location, species, npcType, world.threatLevel())
	crewUID = sb.makeUuid()
	world.setUniqueId(newCrew, crewUID)
	table.insert(storage.crew, crewUID)
end

function recallAllCrewmembers()
	for _,crewID in ipairs(storage.crew) do
      local entityId = world.loadUniqueEntity(crewID)
      if entityId ~= 0 then
      	world.callScriptedEntity(entityId, "tenant.evictTenant")
      end
	end
	storage.crew = {}
end