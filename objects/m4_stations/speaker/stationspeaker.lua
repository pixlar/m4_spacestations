
function init()
	message.setHandler("announce", function() announce(msg) end)
end

function update()
end

function announce(msg)
	object.say(msg)
end