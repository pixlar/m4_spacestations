function init()
	self.eventPeriod = config.getParameter("eventPeriod")
	self.events = config.getParameter("events")
	if storage.lastSeen ~= nil and (os.time() - storage.lastSeen) >= 14400 then
		awayCycles = math.floor((os.time() - storage.lastSeen)/self.eventPeriod)
		awayEffects(awayCycles)
	end
end

function update(dt)
	if os.time() % self.eventPeriod == 0 then
		pickEvent()
	end
end

function uninit()
	storage.lastSeen = os.time()
end

function awayEffects(cycles)
	sb.logInfo("You were gone so long :(")
	storage.lastSeen = nil
end

function pickEvent()
	shuffle(self.events)
	currentEvent = self.events[1]
	sb.logInfo("Current Event: "..currentEvent)
	-- world.spawnStagehand(entity.position(), currentEvent)
end

function shuffle(list)
  for i=1,#list do
    local swapIndex = math.random(1,#list)
    list[i], list[swapIndex] = list[swapIndex], list[i]
  end
end
