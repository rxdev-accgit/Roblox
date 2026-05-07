local HTTPService = game:GetService("HttpService")
local ChatService = game:GetService("Chat")
local plr = game.Players.PlayerAdded:Wait()
local char = plr.CharacterAdded:Wait()
local AIServerUrl = "https://roblox-4-ql5v.onrender.com/rblxAI"
local AIRE = game.ReplicatedStorage:WaitForChild("AIresComm")

local plrname = plr.Name

local function SendInfoToAi(PlayerName, PlayerID, MSG)
	local DataTableFAI = {
		["PLRNAME"] = PlayerName,
		["PLRUSERID"] = PlayerID,	
		["PLRMSG"] = MSG
	} 
	
	local EncodedTable = HTTPService:JSONEncode(DataTableFAI)
	local succes, res = pcall(function()
		return HTTPService:PostAsync(AIServerUrl, EncodedTable, Enum.HttpContentType.ApplicationJson)
	end)
	
	if succes then
		print("Succesfully sent Data to Ai")
		
		local AIresponse = HTTPService:JSONDecode(res).AIres
		AIRE:FireClient(plr, AIresponse)
	else
		warn("Couldnt send data to Ai server, err: ", res)
	end
end

plr.Chatted:Connect(function(msg)
	local PLRID = plr.UserId
	local Character = plr.Character

	--check
	if not plr or not Character then return end

	local PlayerName = plr.Name
	local MSG = msg

	SendInfoToAi(PlayerName, PLRID, MSG)
end)

