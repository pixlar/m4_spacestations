function init()
  object.setInteractive(config.getParameter("interactive", false))
  if storage.state == nil then
    output(config.getParameter("defaultSwitchState", false))
  else
    output(storage.state)
  end
  message.setHandler("switch", function(_, _,switch) 
	output(switch) 
  end)
end

function onInteraction(args)
  output(not storage.state)
end

function onInputNodeChange(args)
  if args.level then
    output(args.node == 0)
  end
end

function output(state)
  storage.state = state
  if state then
    object.setAllOutputNodes(true)
  else
    object.setAllOutputNodes(false)
  end
end
