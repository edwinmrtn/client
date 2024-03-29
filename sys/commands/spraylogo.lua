if not CLIENT then
	return nil
end

local Command = {
	Category = "Player"
}

function Command.Call(Source, File)
	if Source.source == "game" then
		if type(File) == "string" then
			CFG["spraylogo"] = File

			if Options then
				Options.Player.ReloadSpraylogos()
			end
		end
	end
end

function Command.GetSaveString()
	return "spraylogo " .. CFG["spraylogo"]
end

return Command
