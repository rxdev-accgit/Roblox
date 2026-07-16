local Activations = {}

Activations.Sigmoid = {
	Forward = function(z) return 1 / (1 + math.exp(-z)) end,
	Derivative = function(z, a) return a * (1 - a) end,   -- ignores z, uses a
}
Activations.ReLU = {
	Forward = function(z) return math.max(0, z) end,
	Derivative = function(z, a) return z > 0 and 1 or 0 end,  -- ignores a, uses z
}
Activations.Tanh = {
	Forward = math.tanh,
	Derivative = function(z, a)
		return 1 - a^2
	end
}

Activations.LeakyRelu = require(script.LR)

return Activations
