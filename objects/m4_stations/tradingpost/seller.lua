function init()
  self.buyFactor = 1
  object.setInteractive(true)
  self.matchingBuyer = findBuyer()
end

function onInteraction(args)
  local interactData = config.getParameter("interactData")

  interactData.recipes = {}
  local addRecipes = function(items, category)
    for i, item in ipairs(items) do
      interactData.recipes[#interactData.recipes + 1] = generateRecipe(item, category)
    end
  end

  local storeInventory = config.getParameter("storeInventory")
  addRecipes(storeInventory.deeds, "deeds")

  return { "OpenCraftingInterface", interactData }
end

function generateRecipe(itemName, category)
  return {
    input = { {"money", 12} },
    output = itemName,
    groups = { category }
  }
end

function findBuyer()
  if self.matchingBuyer == nil or world.entityExists(self.matchingBuyer) == false then
    local matchingBuyer = world.objectQuery({object.position()[1],object.position()[2]},6)
    for i,j in ipairs(matchingCabinetList) do
      if world.entityName(j) == "postbuyer" then return j end
    end
  end
end