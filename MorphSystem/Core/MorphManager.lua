local MorphManager = {}
local CollectionService = game:GetService("CollectionService")

local PositionalConfigR15 = require(script.Parent.Parent.Config:WaitForChild("PositionalConfig"))
local PositionalConfigR6 = PositionalConfigR15 

local function RigifyModel(ArmorModel: Model)
	if not ArmorModel.PrimaryPart then
		ArmorModel.PrimaryPart = ArmorModel:FindFirstChildWhichIsA("BasePart", true)
	end

	local Prim = ArmorModel.PrimaryPart
	assert(Prim, string.format("[MorphManager]: %s has no BaseParts to use as PrimaryPart", ArmorModel:GetFullName()))

	for _, Part in ipairs(ArmorModel:GetDescendants()) do
		if (Part:IsA("BasePart") or Part:IsA("MeshPart")) and not (Part == Prim) then

			Part.Anchored = false
			Part.CanCollide = false

			local InternalWeld = Instance.new("WeldConstraint")
			InternalWeld.Part0 = Prim
			InternalWeld.Part1 = Part
			InternalWeld.Parent = Part
		end
	end
end

function MorphManager:MorphPlayer(Player: Player, DesiredMorphModel: string, CanOverride: boolean)
	if not Player.Character then
		warn(string.format("[MorphManager]: Player %s does not have a valid character model", Player.UserId))
		return
	end

	local Morph = game.ServerStorage.MorphModels:FindFirstChild(DesiredMorphModel)
	if not Morph then
		warn(string.format("[MorphManager]: Couldnt find Morph Model %s", DesiredMorphModel))
		return
	end

	local RequiredTeam = Morph:GetAttribute("RequiredTeam")
	if RequiredTeam and (not Player.Team or Player.Team.Name ~= RequiredTeam) then
		warn(string.format("[MorphManager]: Player %s is not on the required team (%s) for morph %s", Player.UserId, RequiredTeam, DesiredMorphModel))
		return
	end

	local MorphClone: Model = Morph:Clone()

	local PlayerChar = Player.Character

	-- Detect rig type so we pick the right RigPart attribute + offset config
	local PlayerHumanoid = PlayerChar:FindFirstChildOfClass("Humanoid")
	if not PlayerHumanoid then
		warn(string.format("[MorphManager]: %s has no Humanoid, cannot determine RigType", PlayerChar:GetFullName()))
		MorphClone:Destroy()
		return
	end

	local IsR6 = (PlayerHumanoid.RigType == Enum.HumanoidRigType.R6)
	local RigPartAttributeName = IsR6 and "RigPartR6" or "RigPartR15"
	local PositionalConfig = IsR6 and PositionalConfigR6 or PositionalConfigR15

	if CanOverride == true then
		for _, EquippedMorph in ipairs(CollectionService:GetTagged("EquipedMorph")) do
			if EquippedMorph:IsDescendantOf(PlayerChar) then
				EquippedMorph:Destroy()
			end
		end
	end

	MorphClone:PivotTo(PlayerChar:GetPivot())

	if MorphClone:FindFirstChild("HumanoidRootPart") then
		MorphClone.HumanoidRootPart.Anchored = true
	end
	MorphClone.Parent = PlayerChar
	CollectionService:AddTag(MorphClone, "EquipedMorph")

	for _, MorphPart in ipairs(CollectionService:GetTagged("Morph")) do
		if not (MorphPart:IsDescendantOf(MorphClone)) then continue end

		RigifyModel(MorphPart)

		local RigPartName = MorphPart:GetAttribute(RigPartAttributeName)
		if not RigPartName then
			warn(string.format("[MorphManager]: %s has no %s attribute", MorphPart:GetFullName(), RigPartAttributeName))
			continue
		end

		local SpecifiedCharPart = PlayerChar:FindFirstChild(RigPartName)
		if not SpecifiedCharPart then
			warn(string.format("[MorphManager]: %s has no %s part", PlayerChar:GetFullName(), RigPartName))
			continue
		end

		if not PositionalConfig[MorphClone.Name] or (PositionalConfig[MorphClone.Name] and not PositionalConfig[MorphClone.Name][MorphPart.Name]) then
			warn(string.format("[MorphManager]: PositionalConfig (%s) missing for %s.%s", IsR6 and "R6" or "R15", MorphClone.Name, MorphPart.Name))
			continue
		end

		local RotationOffset = PositionalConfig[MorphClone.Name][MorphPart.Name].Rotation
		local PositionOffset = PositionalConfig[MorphClone.Name][MorphPart.Name].Position

		local TargetCFrame = SpecifiedCharPart.CFrame
			* CFrame.Angles(math.rad(RotationOffset.X), math.rad(RotationOffset.Y), math.rad(RotationOffset.Z))
			* CFrame.new(PositionOffset)

		MorphPart:PivotTo(TargetCFrame)

		local ExternalWeld = Instance.new("WeldConstraint")
		ExternalWeld.Part0 = SpecifiedCharPart
		ExternalWeld.Part1 = MorphPart.PrimaryPart
		ExternalWeld.Parent = MorphPart
	end
end

function MorphManager:DeleteMorph(Player: Player, MorphName)
	assert(Player.Character, string.format("[MorphManager]: Player %s does not have a valid character model", Player.UserId))

	local Morph = Player.Character:FindFirstChild(MorphName)
	assert(Morph, string.format("[MorphManager]: Couldnt find Morph Model %s", MorphName))

	Morph:Destroy()
end

return MorphManager
