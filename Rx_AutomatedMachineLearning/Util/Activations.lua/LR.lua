local LeakyRelu = {}
function LeakyRelu.Forward(x)
	if x > 0 then
		return x
	end
	return 0.01*x
end
function LeakyRelu.Derivative(z, a)
	if z > 0 then
		return 1
	end
	return 0.01
end
return LeakyRelu
