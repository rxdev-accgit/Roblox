local Trainer = {}

local DEBUG = true

local function dprint(...)
	if DEBUG then
		print("[TRAINER_DEBUG]", ...)
	end
end


function Trainer:Fit(Network, TrainingData, Config)

	local Epochs = Config.Epochs or 1000
	local LearningRate = Config.LearningRate or 0.1
	local BatchSize = Config.BatchSize or 4


	for epoch = 1, Epochs do

		local TotalLoss = 0
 
		Network:ZeroGradients()


		for i, Example in ipairs(TrainingData) do


			local Loss =
				Network:Train(
					Example.Input,
					Example.Target,
					LearningRate
				)

			TotalLoss += Loss


			if i % BatchSize == 0 then
				Network:ApplyGradients(LearningRate, BatchSize)
			end
		end


		print(
			"Epoch",
			epoch,
			"Loss",
			TotalLoss / #TrainingData
		)

	end

end


return Trainer
