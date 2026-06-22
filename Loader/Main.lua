--hello i am the loader
local script_key = getgenv().script_key
if game.GameId == 113491250 then -- pf
	print("Found Game Phnatom Forces")
	local source = [[
        script_key = readfile(pegasus_key.txt);
		loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/fb376ba3f7b4fb7815128503025cb019.lua"))()
	]]

	local executor = string.lower(identifyexecutor and identifyexecutor() or "")
	local threadSource = [[
	    for _, func in getgc(false) do
	        if type(func) == "function" and islclosure(func) and debug.getinfo(func).name == "require" and string.find(debug.getinfo(func).source, "ClientLoader") then
	            ]] .. source .. [[
	            break
	        end
	    end
	]]

	local function runSource(runner, getAll)
		for _, actor in getAll() do
			runner(actor, threadSource)
		end
	end

	if string.find(executor, "wave") or string.find(executor, "choco") then
		runSource(run_on_actor, get_deleted_actors)
	elseif string.find(executor, "volt") then
		runSource(run_on_actor, getactors)
	elseif string.find(executor, "potassium") then
		runSource(run_on_thread, getactorthreads)
	elseif getfflag and (string.lower(tostring(getfflag("DebugRunParallelLuaOnMainThread"))) == "true") then
		loadstring(source)()
	elseif setfflag then
		setfflag("DebugRunParallelLuaOnMainThread", "True")

		if queue_on_teleport then
			queue_on_teleport(source)
		end

		game:GetService("TeleportService"):Teleport(game.PlaceId)
	end
elseif game.GameId == 7633926880 then -- bs
	print("Found Game BloxStrike")
	local source = [[
        script_key = readfile(pegasus_key.txt);
		loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/35e09e24fc039b0d90ddd4ca30b0ede0.lua"))()
	]]
	loadstring(source)()
end
