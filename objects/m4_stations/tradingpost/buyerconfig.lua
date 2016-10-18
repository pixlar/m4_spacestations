require("/scripts/util.lua")

function init()
	self.buyer = pane.containerEntityId()
	self.player = pane.playerEntityId()
	self.rememberPrices = false
	self.saleItems = {}
	allTrades = world.getProperty(tradingPost, nil)
	if type(allTrades) ~= nil and allTrades[self.player] ~= nil then
		self.currentTrades = allTrades[self.player]
	else
		self.currentTrades = {}
		self.rememberPrices = true
	end
end

function update(dt)
-- set prices from earlier session
	if not self.rememberPrices then
		for i=0,7 do 
			widget.setText("sellprice"..itemSlot, self.currentTrades[i].price)
		end
		self.rememberPrices = true
	end
	
-- when the contents change, update
	if not compare(self.saleItems, world.containerItems(self.buyer)) then
		sb.logInfo("player "..self.player.." is selling these Items: ")
		for i=0,7 do 
			item = world.containerItemAt(self.buyer, i)
			if item ~= nil then 
				tprint (item)
				sb.logInfo("Sale Price on "..item.name.." is "..getPrice(i))
			else
				widget.setText("sellprice"..i, "")
			end
		end
		self.saleItems = world.containerItems(self.buyer)
	end
	
end

function setPrices()
	self.salesInventory = {}
	for i=0,7 do
		sb.logInfo("Player "..self.player.." has set price of "..getPrice(i).." for item .. in slot "..i..".")
		if world.containerItemAt(self.buyer, i) ~= nil and getPrice(i) ~= 0 then
			item = world.containerItemAt(self.buyer, i)
			item.price = getPrice(i)
		else
			item = {}
		end
		self.salesInventory[i] = item
	end
	world.setProperty(tradingPost[self.player], self.salesInventory)
end

function clearPrice(itemSlot)
	widget.setText("sellprice"..itemSlot, "")
end

function getPrice(itemSlot)
	stringprice = widget.getText("sellprice"..itemSlot)
	if stringprice ~= nil and tonumber(stringprice) then
		return tonumber(stringprice)
	else
		clearPrice(itemSlot)
		return 0
	end
end

function uninit()
	sb.logInfo("closed window")
	setPrices()
end

function tprint (tbl, indent)
	--debbuging function
  
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      sb.logInfo(formatting)
      tprint(v, indent+1)
    elseif type(v) == 'boolean' then
      sb.logInfo(formatting .. tostring(v))      
    else
      sb.logInfo(formatting .. v)
    end
  end
end