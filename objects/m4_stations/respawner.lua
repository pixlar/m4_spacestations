require("/scripts/util.lua")

function init()
		animator.setAnimationState("bed", "default")
end

function update()
	local owner = inhabitant()
	
	if storage.owner ~= nil and not world.entityExists(owner)then
--		sb.logInfo("I have an owner and he is dead")
		setRespawn()
		state(false)
	end
	
	if storage.owner == nil and (storage.respawnTime == nil or storage.respawnTime <= os.time()) then
		spawnInhabitant()
		state(true)
	end
end

function spawnInhabitant()
--	sb.logInfo("spawning owner")
--	local npc = config.getParameter("npc")
	local npcRace = config.getParameter("spawnraces")
	local npcType = config.getParameter("spawnnpctype")
	if type(npcRace) == "table" then 
		shuffle(npcRace)
		npcRace = npcRace[1]
	end
	if type(npcType) == "table" then 
		shuffle(npcType)
		npcType = npcType[1]
	end
	pos = entity.position()
	pos = {pos[1],pos[2]+2}
	owner = world.spawnNpc(pos, npcRace, npcType, world.threatLevel())
--	sb.logInfo("setting unique id")
	newUID = sb.makeUuid()
	world.setUniqueId(owner, newUID)
	storage.owner = newUID
--	if storage.owner ~= nil then 
--		sb.logInfo(storage.owner)
--	end
end

function setRespawn()
	sb.logInfo("my owner is dead")
	local respawnWait = config.getParameter("respawnTimer", 300)
	storage.owner = nil
	storage.respawnTime = os.time() + respawnWait
end

function inhabitant()
	local uid = storage.owner
	if uid == nil then
		return 0
	end
--	sb.logInfo("finding owner")
--	sb.logInfo(storage.owner)
	local owner = world.loadUniqueEntity(uid)
--	sb.logInfo("found owner")
--	sb.logInfo(owner)
	return owner
end

function state(filled)
	if filled then
		--set animation to bed, make interactive
		object.setInteractive(true)
		animator.setAnimationState("bed", "default")
	else
		--set animation state to broken, make not interactive
		object.setInteractive(false)
		animator.setAnimationState("bed", "broken")
	end
end

function die()
	if storage.owner ~= nil then
		despawnOwner()
	end
end

function despawnOwner()
	local entityID = inhabitant()
	world.callScriptedEntity(entityID, "tenant.evictTenant")
end