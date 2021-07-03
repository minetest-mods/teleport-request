--[[
Configuration
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
--]]

-- Timeout delay and mod version.
tpr.timeout_delay = tonumber(minetest.settings:get("tpr.timeout_delay")) or 60
tpr.version = "1.7"

-- Enable teleporting immediately to the specified player for those with `tp_admin` privilege.
tpr.enable_immediate_teleport = minetest.settings:get_bool("tpr.enable_immediate_teleport")

-- Enable area requests using the `tpc` command
--
-- DO NOT CHANGE THE VALUE AT `settingtypes.txt`
-- Only change value at `minetest.conf` and Minetest Settings tab
tpr.enable_area_requests = minetest.settings:get_bool("tpr.enable_area_requests")

-- Set to default (false) if `nil`, because all options are normally
-- `nil`. This will also help with the boolean checks below.
if tpr.enable_area_requests == nil then
	minetest.settings:set_bool("tpr.enable_area_requests", false)
end

-- Set the values of the positions of your places, players will be able to teleport to them (no matter if it is protected, or not).
-- You must activate `enable_tpp_command` in order to make this to work.
tpr.available_places = {
	spawn = {x = 0, y = 0, z = 0},  -- Set coordinates of spawn here.
	shop = {x = 0, y = 0, z = 0},   -- Set coordinates of the shop here.
								    -- Here you can add all the places you want, followed by a comma.
}

-- Enable tpp command
tpr.enable_tpp_command = minetest.settings:get_bool("tpr.enable_tpp_command")

-- Spam prevention
tpr.spam_prevention = minetest.settings:get_bool("tpr.enable_spam_prevention")
