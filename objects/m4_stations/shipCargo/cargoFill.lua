--24 slots
--16 slots

function init()
	self.slotNum = config.getParameter("slotCount")
	self.treasureContents = config.getParameter("treasureContents")
	self.ID = entity.id()
	if root.isTreasurePool(self.treasureContents) then
		self.treasure = root.createTreasure(self.treasureContents, 1)
	end
end

function update()
	if self.treasure ~= nil then
		spawnTreasure(self.treasure)
		self.treasure = nil
	end
end

function spawnTreasure(treasure)
    for _,item in pairs(treasure) do
      world.containerAddItems(self.ID, item)
    end
    object.setConfigParameter("treasureContents", "empty")
end