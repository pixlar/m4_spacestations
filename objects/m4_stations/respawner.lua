function init()
end

function update()
	if storage.npc == nil and (storage.respawnTime == nil or storage.respawnTime <= os.time()) then
		spawnInhabitant()
	end
	if not world.entityExists(inhabitant()) then
		setRespawn()
	end
end

function spawnInhabitant()
	sb.logInfo("spawning owner")
	local npc = config.getParameter("npc")
	pos = entity.position()
	owner = world.spawnNpc(pos, npc[1], npc[2], world.threatLevel())
	newUID = sb.makeUuid()
	world.setUniqueId(owner, newUID)
	storage.npc = newUID
--	state(true)
end

function setRespawn()
	sb.logInfo("my owner is dead")
	storage.npc = nil
	storage.respawnTime = os.time() + 60
end

function inhabitant()
	owner = world.loadUniqueEntity(storage.npc)
	return owner
end

function state(filled)
--	animator.setGlobalTag("owned", filled)
	if filled then
		--set animation to bed, make interactive
		object.setInteractive(true)
		storage.respawnTime = nil
	else
		--set animation state to broken, make not interactive
		object.setInteractive(false)
		setRespawn()
	end
end