local InventoryDataHandler = {}

--Services
local ProfileService = require(game.ServerScriptService.Server.Services:WaitForChild("ProfileService"))
local Players = game:GetService("Players")



local ProfileStore = ProfileService.GetProfileStore(
	"InventoryData",
	{
	["Flashlight"] = false,
	["PaperNotes"] = false,
	["Lighter"] = false,
  }
)

local Profiles = {}


local function PlayerAdded(Player: Player)
	local Profile = ProfileStore:LoadProfileAsync("Player_"..Player.UserId)
	
	if Profile then
		Profile:AddUserId(Player.UserId)
		Profile:Reconcile()
		
		Profile:ListenToRelease(function()
			Profiles[Player] = nil
			Player:Kick()
		end)
		
		if not Player.Parent then
			Profile:Release()
		else
			Profiles[Player] = Profile
			
			print(Profiles[Player].Data) --Debug
		end
	else
		Player:Kick()
	end
end

function InventoryDataHandler:Init()
	for _, Player: Players in Players:GetPlayers() do
		task.spawn(PlayerAdded, Player)
	end
	
	Players.PlayerAdded:Connect(PlayerAdded)
	
	Players.PlayerRemoving:Connect(function(Player)
		if Profiles[Player] then
			Profiles[Player]:Release()
		end
	end)
end

local function GetProfile(Player: Player)
	assert(Profiles[Player], string.format("Profile doesnt exist for Player %s", Player.UserId))
	
	return Profiles[Player]
end

function InventoryDataHandler:GetProfile(Player: Player)
	return Profiles[Player]
end

function InventoryDataHandler:Get(Player: Player, key)
	local Profile = GetProfile(Player)
	
	assert(not (Profile.Data[key] == nil), string.format("Data doesnt exist for key %s", key))
	
	return Profile.Data[key]
end
 
function InventoryDataHandler:Set(Player: Player, key, value)
	local Profile = GetProfile(Player)
	
	assert(not (Profile.Data[key] == nil), string.format("Data does not exist for key: %s", key))
	assert(type(Profile.Data[key]) == type(value))
	
	Profile.Data[key] = value
end

function InventoryDataHandler:Update(Player:Player, key, callback)
	local Profile = GetProfile(Player)
	
	local OldData = self:Get(Player, key)
	local NewData = callback(OldData)
	self:Set(Player, key, NewData)
end


return InventoryDataHandler
