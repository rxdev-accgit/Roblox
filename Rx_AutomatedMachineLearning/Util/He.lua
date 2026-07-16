local He = {}

function He.New(inputs)
	local std = math.sqrt(2 / inputs)

	return (math.random() * 2 - 1) * std * 0.5
end

return He
