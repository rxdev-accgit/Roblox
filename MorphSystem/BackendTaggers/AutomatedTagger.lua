local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

local KEYWORD_TO_RIGPART = {
	{ "chest",    "UpperTorso"   },
	{ "torso",    "UpperTorso"   },
	{ "leftarm",  "LeftUpperArm" },
	{ "rightarm", "RightUpperArm"},
	{ "leftleg",  "LeftUpperLeg" },
	{ "rightleg", "RightUpperLeg"},
}

local function AutoTagArmorModel(ArmorPiece: Model)
	if CollectionService:HasTag(ArmorPiece, "Morph") then
		return
	end

	local NameLower = ArmorPiece.Name:lower()
	local MatchedRigPart = nil

	for _, Pair in ipairs(KEYWORD_TO_RIGPART) do
		local Keyword, RigPart = Pair[1], Pair[2]
		if NameLower:find(Keyword, 1, true) then
			MatchedRigPart = RigPart
			break
		end
	end

	if not MatchedRigPart then
		warn(string.format("[MorphManager]: Could not auto-detect RigPart for '%s' — tag it manually", ArmorPiece:GetFullName()))
		return
	end

	CollectionService:AddTag(ArmorPiece, "Morph")
	ArmorPiece:SetAttribute("RigPart", MatchedRigPart)
end

local function InitializeAllArmorSets()
	local MorphModelsFolder = ServerStorage:FindFirstChild("MorphModels")
	assert(MorphModelsFolder, "[MorphManager]: ServerStorage.MorphModels not found")

	for _, ArmorSet in ipairs(MorphModelsFolder:GetChildren()) do
		if ArmorSet:IsA("Model") then
			for _, ArmorPiece in ipairs(ArmorSet:GetChildren()) do
				if ArmorPiece:IsA("Model") then
					AutoTagArmorModel(ArmorPiece)
				end
			end
		end
	end
end

InitializeAllArmorSets()
