local MPS = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local cds_eventfolder: Folder = game.ReplicatedStorage:WaitForChild("CDS_Events")

local CDSEvent1: BindableEvent = cds_eventfolder:WaitForChild("CDS_ResetEvent")


local FunctionTable = {}

FunctionTable[3592095766] = function(Player: Player)
	CDSEvent1:Fire(Player)
end

local function handleMPS(RIT)
	local PlayerId = RIT.PlayerId
	local ProductId = RIT.ProductId
	local Player:Player = Players:GetPlayerByUserId(PlayerId)
	
	if Player and ProductId then
		local handler = FunctionTable[ProductId]
		
		if handler then
			local succes, res = pcall(handler, Player)
			if not succes then
				warn("[MPS] Error:", res)
				return Enum.ProductPurchaseDecision.NotProcessedYet
			end
			
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
		
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

MPS.ProcessReceipt = handleMPS
