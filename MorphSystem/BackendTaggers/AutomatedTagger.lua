local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

local KEYWORD_TO_RIGPART_R15 = {
	{ "chest",    "UpperTorso"   },
	{ "torso",    "UpperTorso"   },
	{ "leftarm",  "LeftUpperArm" },
	{ "rightarm", "RightUpperArm"},
	{ "leftleg",  "LeftUpperLeg" },
	{ "rightleg", "RightUpperLeg"},
}

local KEYWORD_TO_RIGPART_R6 = {
	{ "chest",    "Torso"     },
	{ "torso",    "Torso"     },
	{ "leftarm",  "Left Arm"  },
	{ "rightarm", "Right Arm" },
	{ "leftleg",  "Left Leg"  },
	{ "rightleg", "Right Leg" },
}

local function MatchKeyword(NameLower: string, KeywordTable)
	for _, Pair in ipairs(KeywordTable) do
		local Keyword, RigPart = Pair[1], Pair[2]
		if NameLower:find(Keyword, 1, true) then
			return RigPart
		end
	end
	return nil
end

local function AutoTagArmorModel(ArmorPiece: Model)
	if CollectionService:HasTag(ArmorPiece, "Morph") then
		return
	end

	local NameLower = ArmorPiece.Name:lower()
	local MatchedR15 = MatchKeyword(NameLower, KEYWORD_TO_RIGPART_R15)
	local MatchedR6 = MatchKeyword(NameLower, KEYWORD_TO_RIGPART_R6)

	if not MatchedR15 and not MatchedR6 then
		warn(string.format("[MorphManager]: Could not auto-detect RigPart (R15 or R6) for '%s' — tag it manually", ArmorPiece:GetFullName()))
		return
	end

	CollectionService:AddTag(ArmorPiece, "Morph")

	if MatchedR15 then
		ArmorPiece:SetAttribute("RigPartR15", MatchedR15)
	else
		warn(string.format("[MorphManager]: '%s' has no R15 match — will be skipped for R15 players", ArmorPiece:GetFullName()))
	end

	if MatchedR6 then
		ArmorPiece:SetAttribute("RigPartR6", MatchedR6)
	else
		warn(string.format("[MorphManager]: '%s' has no R6 match — will be skipped for R6 players", ArmorPiece:GetFullName()))
	end
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
