--This Positional Config module can be changed to fine tune how the armor gets positioned on the player
--Note: When adding new armorsets, make sure each model part of the armor set gets defined into the return table below in the EXACT SAME FORMAT (Meaning each part must have a Position: Vector3 and Rotation: Vector3 (Yes, the names do matter) to prevent positional , orientation and runtime bugs/errors)

return {
	["Enclave Marine Armor | PAMA Morph"] = {
		ChestCOA = {Position = Vector3.new(0, -1, 0), Rotation = Vector3.new(0, 180, 0)},
		LeftarmCOA = {Position = Vector3.new(-0.2, 0.1, 0.1), Rotation = Vector3.new(0, 180, 0)},
		RightarmCOA = {Position = Vector3.new(-0.2, 0.3, 0.1), Rotation = Vector3.new(0, 180, 0)},
		RightlegCOA = {Position = Vector3.new(0, 0, 0), Rotation = Vector3.new(0, 180, 0)},
		LeftlegCOA = {Position = Vector3.new(0, 0, 0), Rotation = Vector3.new(0, 180, 0)},
	},
	
	--... (More config to be added when there's more armor)
	
}
