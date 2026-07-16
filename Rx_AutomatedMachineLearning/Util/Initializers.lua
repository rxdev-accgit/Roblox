local Initializers = {}

function Initializers.Random()
	return math.random() * 2 - 1
end

function Initializers.Xavier(inputs, outputs)
	local limit = math.sqrt(6 / (inputs + outputs))
	return (math.random() * 2 - 1) * limit
end

function Initializers.He(inputs)
	local std = math.sqrt(2 / inputs)
	return (math.random() * 2 - 1) * std
end

Initializers.He = require(script.He)

return Initializers

