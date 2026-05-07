local PCpartTable = require(script:WaitForChild("ShopTable"))


local TableToReturnFCP = {}

TableToReturnFCP.Func1 = function()
	local ChoosedComponents = {}
	
	for ComputerComponent, ComputerComponentTable in pairs(PCpartTable) do --this is the probability logic,the element with the most weight will apear more 
		for i = 1, ComputerComponentTable.Weigth do
			table.insert(ChoosedComponents, ComputerComponent)
		end
	end

	for i = #ChoosedComponents, 2, -1 do --shuffling algorhitm
		local j = math.random(1, i)
		ChoosedComponents[i], ChoosedComponents[j] = ChoosedComponents[j], ChoosedComponents[i]
	end


	local PickedPartTable = {}
	local PickedPartCount = 0
	local UsedPart = {} --table to prevent duplicates

	for _, ComputerCompName in ipairs(ChoosedComponents) do --loop trough chosen computerparts
		if not UsedPart[ComputerCompName] then --prevent duplicates
			local CCMData = PCpartTable[ComputerCompName] -- get the data of the specific computer component chosen in ChoosedComponents
			local Amount = math.random(1, CCMData.Stock) -- random number of stock
			PickedPartCount += 1 -- increment count to prevent alot of parts being in stock
			PickedPartTable[ComputerCompName] = {Amount = Amount, Part = ComputerCompName} -- ??
			UsedPart[ComputerCompName] = true -- prevent duplicates
		end

		if PickedPartCount >= 2 then break end --
	end
	
	--unnecessary stuff
	--[[
	local returntable = {} 
	for i, v in pairs(PickedPartTable) do
		table.insert(returntable, v)
	end]]
	--
	local PriceTable = {
		[1] = 2000,
		[2] = 5000,
		[3] = 10000
	}
	
	return PickedPartTable, PriceTable
end

return TableToReturnFCP
