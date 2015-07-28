if not CLIENT then
	return nil
end

local Command = {
	Category = "Other"
}

function Command.Call(Source, MaxLines)
	if Source.source == "game" then
		if type(MaxLines) == "number" then
			game.Console.MaxLines = MaxLines
			config["console_maxlines"] = MaxLines
		end
	end
end

function Command.GetSaveString()
	return "console_maxlines " .. config["console_maxlines"]
end

return Command
