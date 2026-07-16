local ML_Manager = {}
ML_Manager.__index = ML_Manager
ML_Manager.__internalSys = {}

local Neuron = {}
Neuron.__index = Neuron

local Layer = {}
Layer.__index = Layer

local Network = {}
Network.__index = Network

local DTS = game:GetService("DataStoreService")
local ModelStore = DTS:GetDataStore("NeuralNetworkStorager_CircleAML")

-- ===== DEBUG TOGGLE =====
local DEBUG = false
local function dprint(...)
	if DEBUG then
		print("[ML_DEBUG]", ...)
	end
end
-- =========================

--Util

local Util = game.ServerScriptService.Rx_AML.Util

local Activations = require(Util.Activations)
local Losses = require(Util.Losses)
local Optimizers = require(Util.Optimizers)
local Initializers = require(Util.Initializers)
local Metrics = require(Util.Metrics)
local Schedulers = require(Util.Scheduler)

function ML_Manager.__internalSys.InitNeuron(Network, Inputs: number)
	local self = setmetatable({}, Neuron)

	self.Network = Network
	self.WeightGradients = {}

	self.Weights = {}
	for i = 1, Inputs do
		self.Weights[i] =
			Network.Initializer(
				Inputs
			)
		self.WeightGradients[i] = 0
	end

	self.Bias = 0
	self.BiasGradient = 0

	self.LastInputs = nil
	self.z = nil
	self.a = nil
	self.Delta = nil

	dprint(("Neuron created | inputs=%d | initial bias=%.4f"):format(Inputs, self.Bias))

	return self
end

function ML_Manager.__internalSys.InitLayer(Network, NumNeurons: number, NumInputsPerNeuron: number, Activation)

	local self = setmetatable({}, Layer)

	self.Network = Network
	self.Layer = nil
	self.Activation = Activation

	self.Neurons = {}

	for i = 1, NumNeurons do
		local neuron =
			ML_Manager.__internalSys.InitNeuron(
				Network,
				NumInputsPerNeuron
			)

		neuron.Layer = self

		self.Neurons[i] = neuron
	end

	dprint(("Layer created | neurons=%d | activation=%s")
		:format(
			NumNeurons,
			tostring(Activation)
		))

	return self
end

function ML_Manager.__internalSys.InitNetwork(LayerSizes: {number}, ActivationsList)
	local self = setmetatable({}, Network)

	self.Layers = {}

	self.Loss = Losses.MSE
	self.Optimizer =
		Optimizers.SGD.new()


	self.Initializer =
		function(inputs)
			return Initializers.He.New(inputs)
		end
	self.Metrics = Metrics
	self.Scheduler = nil

	for i = 2, #LayerSizes do
		local NumNeurons = LayerSizes[i]
		local NumInputsPerNeuron = LayerSizes[i-1] --Why? 
		self.Layers[i-1] =
			ML_Manager.__internalSys.InitLayer(
				self,
				NumNeurons,
				NumInputsPerNeuron,
				ActivationsList and ActivationsList[i-1] or Activations.Sigmoid
			)
	end

	dprint(("Network created | layerSizes={%s} | total layers=%d"):format(table.concat(LayerSizes, ","), #self.Layers))

	return self
end

function Neuron:Activate(Inputs)
	self.LastInputs = Inputs


	local z = self.Bias
	for i, input in ipairs(Inputs) do --executing z = W * X + b (for n inputs)
		z += input * self.Weights[i]
	end
	self.z = z

	local a = self.Layer.Activation.Forward(z) --executing activation function [sigm(z) = 1/(1 + e^-z)]
	self.a = a 

	dprint(("Neuron:Activate | z=%.5f -> a=%.5f"):format(z, a))

	return a 
end

function Neuron:Backward(y)
	local DL_a =
		self.Network.Loss:Derivative(
			self.a,
			y
		)  --Executing Derivative of L(a) (loss function)
	local Da_z =
		self.Layer.Activation.Derivative(
			self.z, self.a
		)

	local Delta = DL_a * Da_z

	dprint(("Neuron:Backward | a=%.5f y=%.5f dL_da=%.5f da_dz=%.5f delta=%.5f"):format(self.a, y, DL_a, Da_z, Delta))

	local WeightGradients = {}


	for i, input in ipairs(self.LastInputs) do
		WeightGradients[i] = Delta * input
	end

	for i = 1, #self.Weights do
		self.WeightGradients[i] += WeightGradients[i]
	end

	self.BiasGradient += Delta
	self.Delta = Delta
	return Delta	
end

function Neuron:BackwardHidden(NextLayerNeurons, MyInd)
	local AmountNeuronsBlame = 0

	for _, NextNeuron in ipairs(NextLayerNeurons) do
		AmountNeuronsBlame += NextNeuron.Weights[MyInd] * NextNeuron.Delta
	end

	local Da_z =
		self.Layer.Activation.Derivative(
			self.z, self.a
		)
	local Delta = AmountNeuronsBlame * Da_z
	self.Delta = Delta

	dprint(("Neuron:BackwardHidden | myInd=%d blame=%.5f da_dz=%.5f delta=%.5f"):format(MyInd, AmountNeuronsBlame, Da_z, Delta))

	local WeightGradients = {}

	for i, input in ipairs(self.LastInputs) do
		WeightGradients[i] = Delta * input
	end

	for i = 1, #self.Weights do
		self.WeightGradients[i] += WeightGradients[i]
	end

	self.BiasGradient += Delta
	self.Delta = Delta
	return Delta
end

function Neuron:ZeroGradients()
	for i = 1, #self.WeightGradients do
		self.WeightGradients[i] = 0
	end
	
	self.BiasGradient = 0
end

function Neuron:ApplyGradients(LearningRate, BatchSize)

	for i = 1, #self.Weights do

		local AverageGradient =
			self.WeightGradients[i] / BatchSize

		AverageGradient = math.clamp(
			AverageGradient,
			-1,
			1
		)

		self.Weights[i] =
			self.Network.Optimizer:Update(
				self.Weights[i],
				AverageGradient,
				LearningRate
			)

	end

	local AverageBiasGradient =
		self.BiasGradient / BatchSize

	AverageBiasGradient = math.clamp(
		AverageBiasGradient,
		-1,
		1
	)

	self.Bias =
		self.Network.Optimizer:Update(
			self.Bias,
			AverageBiasGradient,
			LearningRate
		)


	self:ZeroGradients()

end

function Layer:Activate(Inputs)
	local Outputs = {}
	for i, Neuron in ipairs(self.Neurons) do --feed data in neurons 
		Outputs[i] = Neuron:Activate(Inputs)
	end

	dprint(("Layer:Activate | inputs={%s} -> outputs={%s}"):format(table.concat(Inputs, ","), table.concat(Outputs, ",")))

	return Outputs
end

--BackPropagate every neuron
function Layer:Backward(Targets, LearningFactor)
	local Deltas = {}
	for i, Neuron in pairs(self.Neurons) do 
		Deltas[i] = Neuron:Backward(Targets[i])
	end

	return Deltas
end

--Hidden Propagationb
function Layer:BackwardHidden(NextLayer, LearningFactor)
	for i, Neuron in ipairs(self.Neurons) do
		Neuron:BackwardHidden(NextLayer.Neurons, i)
	end
end

function Layer:SerializeData()
	local Data = {}
	for i, Neuron in ipairs(self.Neurons) do
		Data[i] = {
			Weights = Neuron.Weights,
			Bias = Neuron.Bias
		}
	end
	return Data
end

function Layer:DeserializeData(data)
	for i, neuron in ipairs(self.Neurons) do
		neuron.Weights = data[i].Weights
		neuron.Bias = data[i].Bias
	end
end

function Layer:ZeroGradients()
	for _, neuron in ipairs(self.Neurons) do
		neuron:ZeroGradients()
	end
end

function Layer:ApplyGradients(LearningRate, BatchSize)
	for _, neuron in ipairs(self.Neurons) do
		neuron:ApplyGradients(LearningRate, BatchSize)
	end
end

function ML_Manager.SerializeNetwork(layers)
	local networkData = {}
	for i, layer in ipairs(layers) do
		networkData[i] = layer:SerializeData()
	end
	return networkData
end

function ML_Manager.DeserializeNetwork(layers, networkData)
	for i, layer in ipairs(layers) do
		layer:DeserializeData(networkData[i])
	end
end

function ML_Manager.SaveMLNetwork(Layers, ModelName)
	local Data = ML_Manager.SerializeNetwork(Layers)

	local succes, res
	local tries = 0

	repeat
		succes, res = pcall(function()
			ModelStore:SetAsync(ModelName, Data)
		end)
		tries += 1
		task.wait(1)
	until succes or tries >= 5

	if not succes then
		warn("[ML_Manager]: Failed to save ML Network", res)
	else
		dprint("Network saved successfully | attempts=" .. tries)
	end
end

function ML_Manager.LoadMLNetwork(Layers, ModelName)
	local Succes, Data
	local tries = 0

	repeat
		Succes, Data = pcall(function()
			return ModelStore:GetAsync(ModelName)
		end)
		tries += 1
		task.wait(1)
	until Succes or tries >= 5

	if not Succes or not Data then
		warn("[ML_Manager]: Failed to load ML Network", Data)
		return false
	end

	ML_Manager.DeserializeNetwork(Layers, Data)
	dprint("Network loaded successfully | attempts=" .. tries)

	return true
end

function Network:Activate(Inputs)
	local Current = Inputs

	for layerIndex, Layer in ipairs(self.Layers) do
		dprint(("Network:Activate | entering layer %d"):format(layerIndex))
		Current = Layer:Activate(Current)
	end

	return Current --Final Output of layer
end

function Network:Train(Inputs, Targets, LearningFactor)

	dprint(("Network:Train | inputs={%s} targets={%s}"):format(table.concat(Inputs, ","), table.concat(Targets, ",")))

	local Outputs = self:Activate(Inputs)

	local OutputLayer = self.Layers[#self.Layers]

	OutputLayer:Backward(Targets, LearningFactor)

	for i = #self.Layers -1, 1, -1 do
		local Layer = self.Layers[i]
		local NextLayer = self.Layers[i+1]

		dprint(("Network:Train | backprop hidden layer %d"):format(i))

		Layer:BackwardHidden(
			NextLayer,
			LearningFactor
		)
	end

	local loss = self.Metrics.MSE(
		Outputs,
		Targets
	)

	dprint(("Network:Train | loss=%.6f"):format(loss))

	return loss
end

function Network:ZeroGradients()

	for _, layer in ipairs(self.Layers) do
		layer:ZeroGradients()
	end

end


function Network:ApplyGradients(LearningRate, BatchSize)

	for _, layer in ipairs(self.Layers) do
		layer:ApplyGradients(
			LearningRate,
			BatchSize
		)
	end

end

function Network:Save(ModelName)
	ML_Manager.SaveMLNetwork(self.Layers, ModelName)
end

function Network:Load(ModelName)
	return ML_Manager.LoadMLNetwork(self.Layers, ModelName)
end

function Network:SetActivation(Activation)
	self.Activation = Activation
end

function Network:SetLoss(Loss)
	self.Loss = Loss
end

function Network:SetOptimizer(Optimizer)
	self.Optimizer = Optimizer
end

function Network:SetInitializer(Initializer)
	self.Initializer = Initializer
end

function Network:SetScheduler(Scheduler)
	self.Scheduler = Scheduler
end

return ML_Manager
