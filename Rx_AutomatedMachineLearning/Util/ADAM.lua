local Adam = {}
Adam.__index = Adam


function Adam.new()

	return setmetatable({

		LR = 0.001,

		Beta1 = 0.9,
		Beta2 = 0.999,

		Epsilon = 1e-8,

		M = {},
		V = {},
		T = 0

	}, Adam)

end



function Adam:Update(weight, gradient, rate)

	self.T += 1

	local key = tostring(weight)


	self.M[key] =
		self.M[key] or 0

	self.V[key] =
		self.V[key] or 0


	self.M[key] =
		self.Beta1*self.M[key]
		+
		(1-self.Beta1)*gradient


	self.V[key] =
		self.Beta2*self.V[key]
		+
		(1-self.Beta2)*(gradient^2)


	local mHat =
		self.M[key] /
		(1-self.Beta1^self.T)


	local vHat =
		self.V[key] /
		(1-self.Beta2^self.T)


	return weight -
		rate *
		mHat /
		(math.sqrt(vHat)+self.Epsilon)

end


return Adam
