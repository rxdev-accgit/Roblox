local Scheduler = {}

function Scheduler.Exponential(initial, decay, epoch)
	return initial * decay^epoch
end

return Scheduler
