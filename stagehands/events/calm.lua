require "/scripts/util.lua"

function init()
--  if not entity.uniqueId() then
--    stagehand.setUniqueId(sb.makeUuid())
--  end
  
--  local eventType = config.getParameter("eventType")
  
  if not storage.starttime then
  	storage.starttime = os.time()
  end
  
  sb.logInfo("event started at "..storage.starttime..". Ends at"..storage.starttime+60)
  
  -- if this event was abandoned, do stuff and die
	if os.time() >= (storage.starttime + 60) then
		endEvent()
	end
  message.setHandler("endEvent", function(_, _) 
	endEvent()
  end)
end

function update(dt)
	local messages = config.getParameter("messages")
	local psa = messages[1]
	broadcast(psa)
	endEvent()
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

function broadcast(msg)
	world.sendEntityMessage(stationmaster(), "broadcast", msg)
end

function endEvent()
	sb.logInfo("Clearing old event")
	stagehand.die()
end