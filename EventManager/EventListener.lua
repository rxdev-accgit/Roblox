local EventManager = {}
local Listeners = {}

function EventManager:Listen(EventName: string, CallbackFunc)
	if not Listeners[EventName] then
		Listeners[EventName] = {}
	end
	table.insert(Listeners[EventName], CallbackFunc)
	return CallbackFunc
end

function EventManager:Fire(EventName: string, ...)
	if Listeners[EventName] then
		for _, func in ipairs(Listeners[EventName]) do
			func(...)
		end
	end
end

function EventManager:UnListen(EventName: string, CallbackFunc)
	if Listeners[EventName] then
		local index = table.find(Listeners[EventName], CallbackFunc)
		if not index then return end
		table.remove(Listeners[EventName], index)
	end
end

return EventManager
