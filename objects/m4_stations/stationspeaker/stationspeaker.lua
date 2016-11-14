function init()
  message.setHandler("announce", function(_, _,msg) 
	announce(msg) 
  end)
end

function announce(msg)
	object.say(msg)
end