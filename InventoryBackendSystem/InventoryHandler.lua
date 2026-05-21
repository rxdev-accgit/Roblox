local InventoryManager = {}
InventoryManager.__index = InventoryManager

---Services & Frameworks
local InventoryDataHandler = require(script.Parent.DataSaving:WaitForChild("InventoryDataHandler"))

local INVENTORY_KEYS = {
	"Flashlight",
	"PaperNotes",
	"Lighter"
}

function InventoryManager.Initialize(Player: Player)
	local self = setmetatable({}, InventoryManager)

	self.Inventory = {}
	self.Inventory["Player_"..Player.UserId] = {}
	self.Inventory.Template = nil
	self.InventoryItemCount = 0

	print("[InventoryManager] Initialized inventory for Player_"..Player.UserId)
	print("[InventoryManager] Inventory table:", self.Inventory)
	print("[InventoryManager] InventoryItemCount:", self.InventoryItemCount)

	return self
end

function InventoryManager:UpdateInventory(Player: Player, callback, ValueForCheck)
	assert(self.Inventory["Player_"..Player.UserId], "Inventory does not exist for player: "..Player.UserId)
	assert(table.find(INVENTORY_KEYS, ValueForCheck), "Invalid item")
	assert(self.Inventory["Player_"..Player.UserId][ValueForCheck] ~= true, "Inventory already has "..ValueForCheck)

	callback(self.Inventory["Player_"..Player.UserId])

	print("[InventoryManager] UpdateInventory called for Player_"..Player.UserId)
	print("[InventoryManager] Item checked:", ValueForCheck)
	print("[InventoryManager] Inventory state after update:", self.Inventory["Player_"..Player.UserId])

	return true
end

function InventoryManager:LoadInventory(Player: Player)
	print("[InventoryManager] LoadInventory called for Player_"..Player.UserId)
	assert(self.Inventory["Player_"..Player.UserId], "Inventory does not exist for player: "..Player.UserId)
	for _, key in pairs(INVENTORY_KEYS) do
		self.Inventory["Player_"..Player.UserId][key] = InventoryDataHandler:Get(Player, key)
		print("[InventoryManager] Loaded key:", key, "=", self.Inventory["Player_"..Player.UserId][key])
	end
	print("[InventoryManager] LoadInventory complete for Player_"..Player.UserId)
	print("[InventoryManager] Full inventory:", self.Inventory["Player_"..Player.UserId])
	return true
end

function InventoryManager:SaveInventory(Player: Player)
	print("[InventoryManager] SaveInventory called for Player_"..Player.UserId)
	assert(self.Inventory["Player_"..Player.UserId], "Inventory does not exist for player: "..Player.UserId)
	for _, key in pairs(INVENTORY_KEYS) do
		InventoryDataHandler:Set(Player, key, self.Inventory["Player_"..Player.UserId][key])
		print("[InventoryManager] Saved key:", key, "=", self.Inventory["Player_"..Player.UserId][key])
	end
	print("[InventoryManager] SaveInventory complete for Player_"..Player.UserId)
	return true
end

function InventoryManager:GetInventory(Player: Player)
	print("[InventoryManager] GetInventory called for Player_"..Player.UserId)
	assert(self.Inventory["Player_"..Player.UserId], "Inventory does not exist for player: "..Player.UserId)
	print("[InventoryManager] Returning inventory:", self.Inventory["Player_"..Player.UserId])
	return self.Inventory["Player_"..Player.UserId]
end

function InventoryManager:RemoveItem(Player: Player, ItemName: string)
	print("[InventoryManager] RemoveItem called for Player_"..Player.UserId, "| Item:", ItemName)
	assert(self.Inventory["Player_"..Player.UserId], "Inventory does not exist for player: "..Player.UserId)
	assert(table.find(INVENTORY_KEYS, ItemName), "Invalid item")
	self.Inventory["Player_"..Player.UserId][ItemName] = false
	print("[InventoryManager] Removed item:", ItemName, "| Inventory state:", self.Inventory["Player_"..Player.UserId])
end

function InventoryManager:RemoveInventory(Player: Player)
	print("[InventoryManager] RemoveInventory called for Player_"..Player.UserId)
	assert(self.Inventory["Player_"..Player.UserId], "Inventory does not exist for player: "..Player.UserId)
	self:SaveInventory(Player)
	self.Inventory["Player_"..Player.UserId] = nil
	print("[InventoryManager] Inventory removed for Player_"..Player.UserId)
end

function InventoryManager:EquipItem(Player: Player, ItemName)
	assert(self.Inventory["Player_"..Player.UserId], "Inventory does not exist for player: "..Player.UserId)
	assert(table.find(INVENTORY_KEYS, ItemName), "Invalid item")
	assert(self.Inventory["Player_"..Player.UserId][ItemName] == true, "Inventory does not have "..ItemName)

	local ItemTemplate = game.ReplicatedStorage.Items:FindFirstChild(ItemName)
	assert(ItemTemplate, "Item template not found in ReplicatedStorage: " .. ItemName)
	local ItemClone = ItemTemplate:Clone()
	ItemClone.Parent = Player.Character

	print("[InventoryManager] Equipped item:", ItemName)
	return true
end

function InventoryManager:UnequipItem(Player: Player, ItemName)
	assert(self.Inventory["Player_"..Player.UserId], "Inventory does not exist for player: "..Player.UserId)
	assert(table.find(INVENTORY_KEYS, ItemName), "Invalid item")

	local Item = Player.Character:FindFirstChild(ItemName)
	if Item then
		Item:Destroy()
		self.Inventory["Player_"..Player.UserId][ItemName] = true
		print("[InventoryManager] Unequipped item:", ItemName)
		return true
	else
		warn("[InventoryManager] UnequipItem: "..ItemName.." not found on character")
		return false
	end
end

return InventoryManager
