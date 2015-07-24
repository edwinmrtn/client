game = {
	_VERSION = "0.0.0.1a",
	CODENAME = "LuaJIT Rox",
	DATE = "13/07/2015",
}

ffi = require("ffi")
require("src.hook")
require("src.console")
require("src.string")
require("src.gui")
require("src.constants")
require("src.commands")
require("src.config")
require("src.language")
require("src.vector")
require("src.interface")
require("enet")

-- We should remove all trace of loading functions
Hook.Add("load",
	function ()
		love.load = nil
		Hook.Data.load = nil
	end
)