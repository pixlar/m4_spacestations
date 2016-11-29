require "/scripts/util.lua"

function init()
	self.eventPeriod = config.getParameter("eventPeriod")
	self.events = config.getParameter("events")
	if storage.lastSeen ~= nil and (os.time() - storage.lastSeen) >= 14400 then
		awayCycles = math.floor((os.time() - storage.lastSeen)/self.eventPeriod)
		awayEffects(awayCycles)
	end
	resetStation()
  message.setHandler("stationlasers", function(_, _, toggle) 
	stationlasers(toggle)
  end)
  message.setHandler("enemylasers", function(_, _, toggle) 
	enemylasers(toggle)
  end)
  message.setHandler("alarms", function(_, _, toggle) 
	alarms(toggle)
  end)
  message.setHandler("resetStation", function(_, _) 
	resetStation()
  end)
  message.setHandler("broadcast", function(_, _, msg) 
	broadcast(msg)
  end)
end

function update()
-- every 20 minutes, start a new event
	if os.time() % self.eventPeriod == 0 and storage.eventStart ~= os.time() and storage.currentEvent == nil then
		clearEvents()
		startEvent()
	end

-- fire random station lasers
	if (storage.stationlaserswitch) then
--		sb.logInfo("lasers are on")
		local defenselasers = world.objectQuery(entity.position(), 4000, { name="stationlaser" })
		shuffle(defenselasers)
		world.sendEntityMessage(defenselasers[1], "switch", storage.stationlaserswitch)
	end
	
-- fire random lasers
	if (storage.enemylaserswitch) then
		sb.logInfo("enemy lasers are on")
		local enemylasers = world.objectQuery(entity.position(), 4000, { name="enemylaser" })
		shuffle(enemylasers)
		world.sendEntityMessage(enemylasers[1], "switch", true)
		world.sendEntityMessage(enemylasers[2], "switch", true)
	end
end

--toggles the station's lasers on/off
--the lasers fire randomly
function stationlasers(toggle)
	storage.stationlaserswitch = toggle
end

-- toggles enemy lasers on/off (true/false) from a certain direction
-- directions : 1 = north, 2 = east, 3 = south, 4 = west
-- if no direction is specified, all lasers are toggled
function enemylasers(toggle)
	storage.enemylaserswitch = toggle
	sb.logInfo("Toggling enemy lasers")
end

--toggles alarms on/off
function alarms(toggle)
	masterswitches = world.objectQuery(entity.position(), 2000, { name="eventswitch" })
	for _,switch in ipairs(masterswitches) do
		if world.getObjectParameter(switch, "controls") == "alarms" then
			world.sendEntityMessage(switch, "switch", toggle)
		end
	end
end

-- should be called at the end of every event
-- stationevents calls this function BEFORE every event just to make sure
function resetStation()
	stationlasers(false)
	enemylasers(false)
	alarms(false)
	if  storage.currentEvent ~= nil then
		clearEvents()
	end
--	enemylasers(false, "north")
--	enemylasers(false, "east")
--	enemylasers(false, "south")
--	enemylasers(false, "west")
end

-- finds all stationspeakers and broadcasts a message on them
-- note that the messages are only visible if the player is close enough to a speaker
function broadcast(msg)
	sb.logInfo("Broadcast: "..msg)
	speakers = world.objectQuery(entity.position(), 2000, { name="stationspeaker" })
	for _,entityID in ipairs(speakers) do
		world.sendEntityMessage(entityID, "announce", msg)
	end
end

-- destroys any events still around
function clearEvents()
	storage.currentEvent = nil
	local stagehands = world.entityQuery(entity.position(), 20, { includedTypes = {"stagehand"}, withoutEntityId = entity.id()})
	if stagehands ~= nil and #stagehands >= 1 then
		for _,entityId in ipairs(stagehands) do
			world.sendEntityMessage(entityID, "endEvent")
		end
	end
end

function uninit()
	storage.lastSeen = os.time()
end

function awayEffects(cycles)
	sb.logInfo("You were gone so long :(")
	resetStation()
	storage.lastSeen = nil
end

function startEvent()
	shuffle(self.events)
	currentEvent = self.events[1]
	storage.currentEvent = currentEvent
	sb.logInfo("Current Event: "..currentEvent)
	storage.eventStart = os.time()
	local pos = entity.position()
	world.spawnStagehand({pos[1],pos[2]+1}, currentEvent)
end