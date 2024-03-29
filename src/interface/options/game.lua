Options.Game = {}

function Options.Game.Okay()
	local SelectedLanguage = Options.Game.LanguageBox:GetItem(Options.Game.LanguageBox.Selected)
	if SelectedLanguage then
		Config.CFG["cl_lang"] = SelectedLanguage
	end
end

function Options.Game.Cancel()
	Options.Game.LanguageBox:ClearItems()
	for Index, Item in pairs(Lang.List()) do
		Options.Game.LanguageBox:SetItem(Index, Item)
		if Config.CFG["cl_lang"] and Config.CFG["cl_lang"] == Item then
			Options.Game.LanguageBox:Select(Index)
		end
	end
end

function Options.Game.InitializeMenu()
	Options.Panels[3] = gui.CreatePanel(Lang.Get("gui_options_tab_game"), 10, 60, 650, 480, Options.Window)
	gui.CreateLabel(Lang.Get("gui_options_game_language"), 20, 30, Options.Panels[3])
	
	Options.Game.LanguageBox = gui.CreateCombobox(20, 50, 200, 20, Options.Panels[3])
	for Index, Item in pairs(Lang.List()) do
		Options.Game.LanguageBox:SetItem(Index, Item)
		if Config.CFG["cl_lang"] and Config.CFG["cl_lang"] == Item then
			Options.Game.LanguageBox:Select(Index)
		end
	end
end