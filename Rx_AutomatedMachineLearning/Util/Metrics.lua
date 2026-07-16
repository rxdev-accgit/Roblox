local Metrics = {}

function Metrics.MSE(outputs, targets)
	local loss = 0

	for i = 1, #outputs do
		loss += (outputs[i] - targets[i])^2
	end

	return loss / #outputs
end

return Metrics
