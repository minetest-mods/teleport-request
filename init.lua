--[[
Allows players to request from another player to be teleported to them, with much more teleporting features.
Copyright (C) 2014-2021 ChaosWormz and contributors

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
USA

----------------------------------------------------------------------------

Originally made by Traxie21 and released with the WTFPL license.
Forum link: https://forum.minetest.net/viewtopic.php?id=4457

Updates by Zeno, Panquesito7 (David Leal), and ChaosWormz.
License: LGPLv2.1+ for code, CC BY-SA 4.0 for sounds.
--]]

-- Load support for intllib.
local MP = minetest.get_modpath(minetest.get_current_modname())
local S = dofile(MP.."/intllib.lua")

tpr = {
	intllib = S,
	tpr_list = {},
	tphr_list = {},
	tpc_list = {},
	tpn_list = {}
}

-- Clear requests when the player leaves
minetest.register_on_leaveplayer(function(name)
	-- Teleport requests
	if tpr.tpr_list[name] then
		tpr.tpr_list[name] = nil
		return
	end

	if tpr.tphr_list[name] then
		tpr.tphr_list[name] = nil
		return
	end

	-- Area requests
	if tpr.tpc_list[name] then
		tpr.tpc_list[name] = nil
		return
	end

	-- Deny requests
	if tpr.tpn_list[name] then
		tpr.tpn_list[name] = nil
		return
	end
end)

dofile(MP.."/privileges.lua")
dofile(MP.."/config.lua")
dofile(MP.."/functions.lua")
dofile(MP.."/commands.lua")

tp = tpr -- Backwards compatibility

-- Log
if minetest.settings:get_bool("log_mods") then
	minetest.log("action", S("[Teleport Request v@1] Loaded!", tpr.version))
end
