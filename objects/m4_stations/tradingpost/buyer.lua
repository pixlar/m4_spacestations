function init()
	message.setHandler("setPrices", setPrices)
	message.setHandler("setPrice", function(_, _, params) setPrice(params) end)
end

function setPrices(prices)
	object.setConfigParameter("prices", prices)
	sb.logInfo("Prices set")
	for i=0,7 do
		if prices[i] ~= nil then sb.logInfo("$$"..prices[i]) end
	end
end

function setPrice(params)
	itemSlot = params[1]
	price = params[2]
	player = params[3]
	sb.logInfo("slot ".. itemSlot.." being set")
	sb.logInfo("set at "..price)
end