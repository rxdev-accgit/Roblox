local RE = game.ReplicatedStorage:WaitForChild("RE").ShopCommunication

if RE then RE:FireAllClients() end


local CYCLE_TIME = 60 
local signal = "Reset_Shop"
local lastresetsecond = -1

while true do
	local currenttime = os.time()
	local TimeDuringCycle = currenttime % CYCLE_TIME
	local TimeLeft = CYCLE_TIME - TimeDuringCycle
	
	if TimeDuringCycle == 0 then
		TimeLeft = 0
	end
	
	RE:FireAllClients(TimeLeft)
	
	if TimeDuringCycle == 0 and not (currenttime == lastresetsecond) then
		RE:FireAllClients(signal)
		lastresetsecond = currenttime
	end

	task.wait(1)
end
