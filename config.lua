--[[
Configuration

Copyright (C) 2015-2019 ChaosWormz

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
--]]

-- Load support for intllib.
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

-- Timeout delay and mod version.
tp.timeout_delay = tonumber(minetest.settings:get("tp.timeout_delay")) or 60
tp.version = "1.5"

-- Enable teleporting immediately to the specified player for those with "tp_admin" privilege.
tp.enable_immediate_teleport = minetest.settings:get_bool("tp.enable_immediate_teleport")

local chatmsg, source, target, name2, target_coords, pos

-- Set the values of the positions of your places, players will be able to teleport to them (no matter if it is protected, or not).
-- You must activate "enable_tpp_command" in order to make this to work.
tp.available_places = {
	spawn = {x = 0, y = 0, z = 0}, -- Set coordinates of spawn here.
	shop = {x = 0, y = 0, z = 0}, -- Set coordinates of the shop here.
}

-- Enable tpp command
tp.enable_tpp_command = minetest.settings:get_bool("tp.enable_tpp_command")

-- Register privileges
minetest.register_privilege("tp", {
	description = S("Let players teleport to other players (request will be sent)"),
	give_to_singleplayer = false,
	give_to_admin = true,
})

minetest.register_privilege("tp_admin", {
	description = S("Gives full admin-access to a player."),
	give_to_singleplayer = false,
	give_to_admin = true,
})

minetest.register_privilege("tp_tpc", {
	description = S("Allow player to teleport to coordinates (if allowed by area protection)"),
	give_to_singleplayer = false,
	give_to_admin = true,
})
