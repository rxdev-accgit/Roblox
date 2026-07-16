local Optimizers = {}

Optimizers.SGD = {}
Optimizers.SGD.__index = Optimizers.SGD

function Optimizers.SGD.new()
	return setmetatable({}, Optimizers.SGD)
end

function Optimizers.SGD:Update(weight, gradient, lr)
	return weight - lr * gradient
end

Optimizers.Adam = require(script.ADAM)

return Optimizers
