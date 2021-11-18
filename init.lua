
-- Public API (Also used by some internals)
nutra_paste = {}

nutra_paste.S = minetest.get_translator("nutra_paste")
nutra_paste.modpath = minetest.get_modpath("nutra_paste")
nutra_paste.VERSION = "1.0"

if minetest.registered_nodes["default:stone"] then
    nutra_paste.GAMEMODE = "MTG"
elseif minetest.registered_nodes["mcl_deepslate:deepslate"] then
    nutra_paste.GAMEMODE = "MCL5"
elseif minetest.registered_nodes["mcl_core:stone"] then
    nutra_paste.GAMEMODE = "MCL2"
else
    nutra_paste.GAMEMODE = "???"
end

dofile(nutra_paste.modpath.."/settings.lua") -- Settings
dofile(nutra_paste.modpath.."/tool_belt.lua") -- Utility functions
dofile(nutra_paste.modpath.."/register.lua")

nutra_paste.tools.log("Detected gamemode "..nutra_paste.GAMEMODE..".")
nutra_paste.tools.log("Running version: "..nutra_paste.VERSION)