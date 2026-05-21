local InventoryManager = require(game.ServerScriptService.Server.Systems.InventorySystem:WaitForChild("InventoryManager"))
local InventoryDataHandler = require(game.ServerScriptService.Server.Systems.InventorySystem.DataSaving:WaitForChild("InventoryDataHandler"))
InventoryDataHandler:Init()

--Inventory System Events
local InventorySystemEvents: Folder = game.ReplicatedStorage.RemoteEvents:WaitForChild("InventoryEvents")
local IVS_Event1: RemoteEvent = InventorySystemEvents:WaitForChild("IVS_UpdateInventory")
local IVS_Event2: RemoteEvent = InventorySystemEvents:WaitForChild("IVS_RemoveItemFromInventory")
local IVS_Event3: RemoteEvent = InventorySystemEvents:WaitForChild("IVS_EquipItem")
local IVS_Event4: RemoteEvent = InventorySystemEvents:WaitForChild("IVS_UnequipItem")


local Players = game:GetService("Players")

local PlayerInventorySystems = {}

local function Init(player: Player)
	local attempts = 0
	while not InventoryDataHandler:GetProfile(player) and attempts < 10 do
		print("[InventoryServer] Waiting for profile to load for:", player.Name, "| Attempt:", attempts + 1)
		task.wait(0.5)
		attempts += 1
	end

	if not InventoryDataHandler:GetProfile(player) then
		warn("[InventoryServer] Profile never loaded for:", player.Name)
		return
	end

	local Inventory = InventoryManager.Initialize(player)
	Inventory:LoadInventory(player)
	print("[InventoryManager] Inventory initialized for player: "..player.Name)
	PlayerInventorySystems[player.UserId] = Inventory
end

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(Init, player)
end

local function OnLeave(Player: Player)
	local Inventory = PlayerInventorySystems[Player.UserId]

	if Inventory then
		Inventory:RemoveInventory(Player)
		PlayerInventorySystems[Player.UserId] = nil
	end
end


IVS_Event1.OnServerEvent:Connect(function(Player: Player, ItemName: string)
	local Inventory = PlayerInventorySystems[Player.UserId]
	if Inventory then
		Inventory:UpdateInventory(Player, function(Data)
			Data[ItemName] = true
		end, ItemName)
	end	
end)

IVS_Event2.OnServerEvent:Connect(function(Player: Player, ItemName: string)
	local Inventory = PlayerInventorySystems[Player.UserId]
	if Inventory then
		Inventory:RemoveItem(Player, ItemName)
	end	
end)

IVS_Event3.OnServerEvent:Connect(function(Player: Player, ItemName:string)
	local Inventory = PlayerInventorySystems[Player.UserId]
	if Inventory then
		Inventory:EquipItem(Player, ItemName)
	end
end)

IVS_Event4.OnServerEvent:Connect(function(Player: Player, ItemName)
	local Inventory = PlayerInventorySystems[Player.UserId]
	if Inventory then
		Inventory:UnequipItem(Player, ItemName)
	end
end)

Players.PlayerRemoving:Connect(OnLeave)
Players.PlayerAdded:Connect(Init)




