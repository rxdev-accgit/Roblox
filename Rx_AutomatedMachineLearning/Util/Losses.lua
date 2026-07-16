local Losses = {}

Losses.MSE = {}

function Losses.MSE:Loss(output, target)
	return (output - target)^2
end

function Losses.MSE:Derivative(output, target)
	return 2 * (output - target)
end

return Losses
