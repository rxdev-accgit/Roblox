--Note: This can be changed to also implement any type of training that you want to do, with however much neurons you want, the bias, learingrate and other fundamental variables are to be changed as you desire

local ML_Manager =
	require(game.ServerScriptService.Rx_AML.Core.ML_Manager)
local Activations =
	require(game.ServerScriptService.Rx_AML.Util.Activations)



local RADIUS = 0.5
local MODEL_NAME = "Rx_AML-CIRCLE-CLASSIFIER"

local function GenerateExample()
	local x = math.random() * 2 - 1
	local y = math.random() * 2 - 1
	local insideCircle = (x*x + y*y) <= (RADIUS * RADIUS)
	return {
		Input = {x, y},
		Target = {insideCircle and 1 or 0}
	}
end

local function GenerateDataset(size)
	local dataset = {}
	for i = 1, size do
		dataset[i] = GenerateExample()
	end
	return dataset
end


local Network =
	ML_Manager.__internalSys.InitNetwork(
		{
			2,
			8,
			1
		},
		{
			Activations.ReLU,
			Activations.Sigmoid
		}
	)


local loaded = Network:Load(MODEL_NAME)
if loaded then
	print("[MLCaller] Loaded previous weights — continuing training on top of them.")
else
	print("[MLCaller] No saved network found — starting from fresh random weights.")
end


local TrainingSize = 500
local Epochs = 3000
local LearningRate = 0.1
local BatchSize = 10

for epoch = 1, Epochs do
	local Dataset = GenerateDataset(TrainingSize)
	local TotalLoss = 0

	Network:ZeroGradients()

	for i, Example in ipairs(Dataset) do
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

	if epoch % 100 == 0 then
		print(
			"Epoch:", epoch,
			"Avg Loss:", TotalLoss / TrainingSize
		)
	end

	if epoch % 10 == 0 then
		task.wait()
	end
end


print("[MLCaller] Training complete — saving network as", MODEL_NAME)
Network:Save(MODEL_NAME)

print("--- TESTING ON NEW, UNSEEN POINTS ---")

local TestSet = GenerateDataset(10)
local correct = 0

for _, Example in ipairs(TestSet) do
	local prediction = Network:Activate(Example.Input)
	local predictedClass = prediction[1] > 0.5 and 1 or 0
	local actualClass = Example.Target[1]

	if predictedClass == actualClass then
		correct += 1
	end

	print(string.format(
		"(%.2f, %.2f) -> raw=%.4f | predicted=%d | actual=%d %s",
		Example.Input[1], Example.Input[2],
		prediction[1],
		predictedClass,
		actualClass,
		predictedClass == actualClass and "++" or "--"
		))
end

print(string.format("Accuracy on unseen points: %d/10 (%.0f%%)", correct, (correct/10)*100))
