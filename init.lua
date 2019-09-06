--[[
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

----------------------------------------------------------------------------

Originally made by Traxie21 and released with the WTFPL license.
Forum link: https://forum.minetest.net/viewtopic.php?id=4457

Updates by Zeno, Panquesito7 and ChaosWormz.
License: LGPL-2.1 for everything.

Optional dependencies: areas, intllib
New release by RobbieF under new mod: tps_teleport - http://blog.minetest.tv/teleport-request/
--]]

tp = {}

-- Load support for intllib.
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

-- Load configuration.
dofile(MP.."/config.lua")

tp.tpr_list = {}
tp.tphr_list = {}

local map_size = 30912
function tp.can_teleport(to)
	return to.x < map_size and to.x > -map_size and to.y < map_size and to.y > -map_size and to.z < map_size and to.z > -map_size
end

-- Teleport player to a player (used in "/tpr" and in "/tphr" command).
function tp.tpr_teleport_player()
	local target_coords = source:get_pos()
	local target_sound = target:get_pos()
	target:set_pos(tp.find_free_position_near(target_coords))
	minetest.sound_play("whoosh", {pos = target_coords, gain = 0.5, max_hear_distance = 10})
	minetest.sound_play("whoosh", {pos = target_sound, gain = 0.5, max_hear_distance = 10})
	--tp.parti2(target_coords)
end

-- TPC & TPJ
function tp.tpc_teleport_player(player)
	local pname = minetest.get_player_by_name(player)
	minetest.sound_play("whoosh", {pos = pname:get_pos(), gain = 0.5, max_hear_distance = 10})
	pname:set_pos(tp.find_free_position_near(target_coords))
	minetest.sound_play("whoosh", {pos = target_coords, gain = 0.5, max_hear_distance = 10})
	--tp.parti2(target_coords)
end

-- TPP
function tp.tpp_teleport_player(player)
	local pname = minetest.get_player_by_name(player)
	minetest.sound_play("whoosh", {pos = pname:get_pos(), gain = 0.5, max_hear_distance = 10})
	pname:set_pos(tp.find_free_position_near(pos))
	minetest.sound_play("whoosh", {pos = pos, gain = 0.5, max_hear_distance = 10})
	--tp.parti2(target_coords)
end

function tp.find_free_position_near(pos)
	local tries = {
		{x=1,y=0,z=0},
		{x=-1,y=0,z=0},
		{x=0,y=0,z=1},
		{x=0,y=0,z=-1},
	}
	for _,d in pairs(tries) do
		local p = vector.add(pos, d)
		if not minetest.registered_nodes[minetest.get_node(p).name].walkable then
			return p, true
		end
	end
	return pos, false
end

function tp.parti(pos)
	minetest.add_particlespawner(50, 0.4,
		{x=pos.x + 0.5, y=pos.y, z=pos.z + 0.5}, {x=pos.x - 0.5, y=pos.y, z=pos.z - 0.5},
		{x=0, y=5, z=0}, {x=0, y=0, z=0},
		{x=0, y=5, z=0}, {x=0, y=0, z=0},
		3, 5,
		3, 5,
		false,
		"tps_portal_parti.png")
end

function tp.parti2(pos)
	minetest.add_particlespawner(50, 0.4,
		{x=pos.x + 0.5, y=pos.y + 10, z=pos.z + 0.5}, {x=pos.x - 0.5, y=pos.y, z=pos.z - 0.5},
		{x=0, y=-5, z=0}, {x=0, y=0, z=0},
		{x=0, y=-5, z=0}, {x=0, y=0, z=0},
		3, 5,
		3, 5,
		false,
		"tps_portal_parti.png")
end

-- Teleport Request System
function tp.clear_tpr_list(name)
	if tp.tpr_list[name] then
		tp.tpr_list[name] = nil
		return
	end
end

function tp.clear_tphr_list(name)
	if tp.tphr_list[name] then
		tp.tphr_list[name] = nil
		return
	end
end

-- Clear requests when the player leaves
minetest.register_on_leaveplayer(function(name)
	if tp.tpr_list[name] then
		tp.tpr_list[name] = nil
		return
	end
	
	if tp.tphr_list[name] then
		tp.tphr_list[name] = nil
		return
	end
end)

function tp.tpr_send(sender, receiver)
	-- Compatibility with beerchat (UNTESTED)
		if minetest.get_modpath("beerchat") and not minetest.check_player_privs(sender, {tp_admin = true}) then
			if minetest.get_player_by_name(sender):get_attribute("beerchat:muted:" .. sender) then
				minetest.chat_send_player(sender, S("You are not allowed to send requests because you're muted."))
				if minetest.get_modpath("chat2") then
					chat2.send_message(minetest.get_player_by_name(sender), S("You are not allowed to send requests because you're muted."), 0xFFFFFF)
				end
			return
		end
	end
	if minetest.check_player_privs(sender, {tp_admin = true}) and tp.enable_immediate_teleport then
	if receiver == "" then
		minetest.chat_send_player(sender, S("Usage: /tpr <Player name>"))
		if minetest.get_modpath("chat2") then
			chat2.send_message(minetest.get_player_by_name(sender), S("Usage: /tpr <Player name>"), 0xFFFFFF)
		end
            return
	end
	if not minetest.get_player_by_name(receiver) then
		minetest.chat_send_player(sender, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online"))
		if minetest.get_modpath("chat2") then
			chat2.send_message(minetest.get_player_by_name(sender), S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online"), 0xFFFFFF)
		end	
	    return
	end
		tp.tpr_list[receiver] = sender
	tp.tpr_accept(receiver)
			minetest.chat_send_player(sender, S("You are teleporting to @1.", receiver))
			if minetest.get_modpath("chat2") then
				chat2.send_message(minetest.get_player_by_name(sender), S("You are teleporting to @1.", receiver), 0xFFFFFF)
			end
		return
	end
	
	if receiver == "" then
		minetest.chat_send_player(sender, S("Usage: /tpr <Player name>"))
			if minetest.get_modpath("chat2") then
				chat2.send_message(minetest.get_player_by_name(sender), S("Usage: /tpr <Player name>"), 0xFFFFFF)
			end	
		return
	end

	if not minetest.get_player_by_name(receiver) then
		minetest.chat_send_player(sender, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online"))
		if minetest.get_modpath("chat2") then
			chat2.send_message(minetest.get_player_by_name(sender), S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online"), 0xFFFFFF)
		end
		return
	end
	if minetest.get_modpath("chat2") then
		chat2.send_message(minetest.get_player_by_name(receiver), S("@1 is requesting to teleport to you. /tpy to accept", sender), 0xFFFFFF)
		chat2.send_message(minetest.get_player_by_name(sender), S("Teleport request sent! It will timeout in @1 seconds", tp.timeout_delay), 0xFFFFFF)
	end
	minetest.chat_send_player(receiver, S("@1 is requesting to teleport to you. /tpy to accept", sender))
	minetest.chat_send_player(sender, S("Teleport request sent! It will timeout in @1 seconds", tp.timeout_delay))
	-- Write name values to list and clear old values.
		tp.tpr_list[receiver] = sender
		-- Teleport timeout delay
		minetest.after(tp.timeout_delay, function(name)
		if tp.tpr_list[name] then
			tp.tpr_list[name] = nil
			minetest.chat_send_player(sender, S("Request timed-out."))
			minetest.chat_send_player(receiver, S("Request timed-out."))
			if minetest.get_modpath("chat2") then
				chat2.send_message(minetest.get_player_by_name(sender), S("Request timed-out."), 0xFFFFFF)
				chat2.send_message(minetest.get_player_by_name(receiver), S("Request timed-out."), 0xFFFFFF)
			end
			return
		end
	end, receiver)
end

function tp.tphr_send(sender, receiver)
	-- Compatibility with beerchat (UNTESTED)
		if minetest.get_modpath("beerchat") and not minetest.check_player_privs(sender, {tp_admin = true}) then
			if minetest.get_player_by_name(sender):get_attribute("beerchat:muted:" .. sender) then
				minetest.chat_send_player(sender, S("You are not allowed to send requests because you're muted."))
				if minetest.get_modpath("chat2") then
					chat2.send_message(minetest.get_player_by_name(sender), S("You are not allowed to send requests because you're muted."), 0xFFFFFF)
				end
			return
		end
	end
	if minetest.check_player_privs(sender, {tp_admin = true}) and tp.enable_immediate_teleport then
	if receiver == "" then
		minetest.chat_send_player(sender, S("Usage: /tphr <Player name>"))
		if minetest.get_modpath("chat2") then
			chat2.send_message(minetest.get_player_by_name(sender), S("Usage. /tphr <Player name>"), 0xFFFFFF)
		end
	    return	
	end
	if not minetest.get_player_by_name(receiver) then
		minetest.chat_send_player(sender, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online"))
		if minetest.get_modpath("chat2") then
			chat2.send_message(minetest.get_player_by_name(sender), S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online"), 0xFFFFFF)
		end
	    return
	end
		tp.tphr_list[receiver] = sender
	tp.tpr_accept(receiver)
		minetest.chat_send_player(sender, S("@1 is teleporting to you.", receiver))
		if minetest.get_modpath("chat2") then
			chat2.send_message(minetest.get_player_by_name(sender), S("@1 is teleporting to you.", receiver), 0xFFFFFF)
		end
		return
	end
	if receiver == "" then
		minetest.chat_send_player(sender, S("Usage: /tphr <Player name>"))
		if minetest.get_modpath("chat2") then
			chat2.send_message(minetest.get_player_by_name(sender), S("Usage. /tphr <Player name>"), 0xFFFFFF)
		end
		return
	end

	if not minetest.get_player_by_name(receiver) then
		minetest.chat_send_player(sender, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online"))
		if minetest.get_modpath("chat2") then
				chat2.send_message(minetest.get_player_by_name(sender), S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online"), 0xFFFFFF)
			end
		return
	end
	if minetest.get_modpath("chat2") then
		chat2.send_message(minetest.get_player_by_name(receiver), S("@1 is requesting that you teleport to them. /tpy to accept; /tpn to deny", sender), 0xFFFFFF)
		chat2.send_message(minetest.get_player_by_name(sender), S("Teleport request sent! It will timeout in @1 seconds", tp.timeout_delay), 0xFFFFFF)
	end
	minetest.chat_send_player(receiver, S("@1 is requesting that you teleport to them. /tpy to accept; /tpn to deny", sender))
	minetest.chat_send_player(sender, S("Teleport request sent! It will timeout in @1 seconds", tp.timeout_delay))
	-- Write name values to list and clear old values.
		tp.tphr_list[receiver] = sender
		-- Teleport timeout delay
		minetest.after(tp.timeout_delay, function(name)
		if tp.tphr_list[name] then
			tp.tphr_list[name] = nil
			minetest.chat_send_player(sender, S("Request timed-out."))
			minetest.chat_send_player(receiver, S("Request timed-out."))
				if minetest.get_modpath("chat2") then
					chat2.send_message(minetest.get_player_by_name(sender), S("Request timed-out"), 0xFFFFFF)
					chat2.send_message(minetest.get_player_by_name(receiver), S("Request timed-out"), 0xFFFFFF)
				end	
			return
		end
	end, receiver)
end

function tp.tpc_send(player, coordinates)

	local posx,posy,posz = string.match(coordinates, "^(-?%d+), (-?%d+), (-?%d+)$")
	local pname = minetest.get_player_by_name(player)

	if posx ~= nil or posy ~= nil or posz ~= nil then
	  posx = tonumber(posx) + 0.0
	  posy = tonumber(posy) + 0.0
	  posz = tonumber(posz) + 0.0
	end

	if posx==nil or posy==nil or posz==nil or string.len(posx) > 6 or string.len(posy) > 6 or string.len(posz) > 6 then
		minetest.chat_send_player(player, S("Usage: /tpc <x, y, z>"))
		if minetest.get_modpath("chat2") then
			chat2.send_message(minetest.get_player_by_name(player), S("Usage: /tpc <x, y, z>"), 0xFFFFFF)
		end
		return nil
	end

	target_coords = {x=posx, y=posy, z=posz}

	if tp.can_teleport(target_coords) == false then
		minetest.chat_send_player(player, S("You cannot teleport to a location outside the map!"))
	if minetest.get_modpath("chat2") then
		chat2.send_message(minetest.get_player_by_name(player), S("You cannot teleport to a location outside the map!"), 0xFFFFFF)
	end
		return nil
	end

	-- If the area is protected, reject the user's request to teleport to these coordinates
	-- In future release we'll actually query the player who owns the area, if they're online, and ask for their permission.
	-- Admin user (priv "tp_admin") overrides all protection
	if minetest.check_player_privs(pname, {tp_admin = true}) then
		tp.tpc_teleport_player(player)
		minetest.chat_send_player(player, S("Teleporting to: @1, @2, @3", posx, posy, posz))
		if minetest.get_modpath("chat2") then
			chat2.send_message(minetest.get_player_by_name(player), S("Teleporting to: @1, @2, @3", posx, posy, posz), 0xFFFFFF)
		end
	else
		if minetest.check_player_privs(pname, {tp_tpc = true}) then
			local protected = minetest.is_protected(target_coords,pname)
			if protected and minetest.get_modpath("areas") then
				if not areas:canInteract(target_coords, player) then
					local owners = areas:getNodeOwners(target_coords)
					minetest.chat_send_player(player, S("Error: @1 is protected by @2.", minetest.pos_to_string(target_coords), table.concat(owners, ", ")))
					if minetest.get_modpath("chat2") then
						chat2.send_message(minetest.get_player_by_name(player), S("Error: @1 is protected by @2.", minetest.pos_to_string(target_coords), table.concat(owners, ", ")), 0xFFFFFF)
					end
					return
				end
			end
			tp.tpc_teleport_player(player)
			minetest.chat_send_player(player, S("Teleporting to: @1, @2, @3", posx, posy, posz))
			if minetest.get_modpath("chat2") then
				chat2.send_message(minetest.get_player_by_name(player), S("Teleporting to: @1, @2, @3", posx, posy, posz), 0xFFFFFF)
			end
		else
			minetest.chat_send_player(player, S("Error: You do not have permission to teleport to those coordinates."))
			if minetest.get_modpath("chat2") then
				chat2.send_message(minetest.get_player_by_name(player), S("Error: You do not have permission to teleport to those coordinates."), 0xFFFFFF)
			end
			return
		end
	end
end

function tp.tpr_deny(name)
	if tp.tpr_list[name] then
		name2 = tp.tpr_list[name]
		minetest.chat_send_player(name2, S("Teleport request denied."))
		minetest.chat_send_player(name, S("You denied the request @1 sent you.", name2))
		if minetest.get_modpath("chat2") then
			chat2.send_message(minetest.get_player_by_name(name2), S("Teleport request denied."), 0xFFFFFF)
			chat2.send_message(minetest.get_player_by_name(name), S("You denied the request @1 sent you.", name2), 0xFFFFFF)
		end
		tp.tpr_list[name] = nil
	elseif tp.tphr_list[name] then
		name2 = tp.tphr_list[name]
		minetest.chat_send_player(name2, S("Teleport request denied."))
		minetest.chat_send_player(name, S("You denied the request @1 sent you.", name2))
		if minetest.get_modpath("chat2") then
			chat2.send_message(minetest.get_player_by_name(name2), S("Teleport request denied."), 0xFFFFFF)
			chat2.send_message(minetest.get_player_by_name(name), S("You denied the request @1 sent you.", name2), 0xFFFFFF)
		end
		tp.tphr_list[name] = nil
	else
		minetest.chat_send_player(name, S("Usage: /tpn allows you to deny teleport requests sent to you by other players."))
		if minetest.get_modpath("chat2") then
			chat2.send_message(minetest.get_player_by_name(name), S("Usage: /tpn allows you to deny teleport requests sent to you by other players."), 0xFFFFFF)
		end
		return
	end
end

-- Teleport Accept Systems
function tp.tpr_accept(name, param)
	-- Check to prevent constant teleporting.
	if not tp.tpr_list[name] and not tp.tphr_list[name] then
		minetest.chat_send_player(name, S("Usage: /tpy allows you to accept teleport requests sent to you by other players"))
		if minetest.get_modpath("chat2") then
			chat2.send_message(minetest.get_player_by_name(name), S("Usage: /tpy allows you to accept teleport requests sent to you by other players"), 0xFFFFFF)
		end
		return
	end
	
	if tp.tpr_list[name] then
		name2 = tp.tpr_list[name]
		source = minetest.get_player_by_name(name)
		target = minetest.get_player_by_name(name2)
		chatmsg = S("@1 is teleporting to you.", name2)
		tp.tpr_list[name] = nil
	elseif tp.tphr_list[name] then
		name2 = tp.tphr_list[name]
		source = minetest.get_player_by_name(name2)
		target = minetest.get_player_by_name(name)
		chatmsg = S("You are teleporting to @1.", name2)
		tp.tphr_list[name] = nil
	else
		return
	end
	
	-- Could happen if either player disconnects (or timeout); if so just abort
	if not source
	or not target then
		minetest.chat_send_player(name, S("@1 doesn't exist, or just disconnected/left (by timeout).", name2))
		return
	end
	tp.tpr_teleport_player()
	minetest.chat_send_player(name2, S("Request Accepted!"))
	minetest.chat_send_player(name, chatmsg)
	if minetest.get_modpath("chat2") then
		chat2.send_message(minetest.get_player_by_name(name2), S("Request Accepted!"), 0xFFFFFF)
		chat2.send_message(minetest.get_player_by_name(name), chatmsg, 0xFFFFFF)
	end
end

-- Teleport Jump - Relative Position Teleportation by number of nodes
function tp.tpj(player, param)
	local pname = minetest.get_player_by_name(player)

	if param == "" then
		minetest.chat_send_player(player, S("Usage: <x|y|z> <number>"))
		if minetest.get_modpath("chat2") then
			chat2.send_message(minetest.get_player_by_name(player), S("Usage: <x|y|z> <number>"), 0xFFFFFF)
		end
		return false
	end

	local args = param:split(" ") -- look into this. Can it crash if the player does not have two parameters?
	if #args < 2 then
		minetest.chat_send_player(player, S("Usage: <x|y|z> <number>"))
		if minetest.get_modpath("chat2") then
			chat2.send_message(minetest.get_player_by_name(player), S("Usage: <x|y|z> <number>"), 0xFFFFFF)
		end
		return false
	end
	
	if not tonumber(args[2]) then
		return false, S("Not a number!")
	end
	
	-- Initially generate the target coords from the player's current position (since it's relative) and then perform the math.
	target_coords = minetest.get_player_by_name(player):get_pos()
	if args[1] == "x" then
		target_coords["x"] = target_coords["x"] + tonumber(args[2])
	elseif args[1] == "y" then
		target_coords["y"] = target_coords["y"] + tonumber(args[2])
	elseif args[1] == "z" then
		target_coords["z"] = target_coords["z"] + tonumber(args[2])
	else
		minetest.chat_send_player(player, S("Not a valid axis. Valid options are X, Y or Z"))
		if minetest.get_modpath("chat2") then
			chat2.send_message(minetest.get_player_by_name(player), S("Not a valid axis. Valid options are X, Y or Z"), 0xFFFFFF)
		end
		return
	end
	if tp.can_teleport(target_coords) == false then
		minetest.chat_send_player(player, S("You cannot teleport to a location outside the map!"))
		if minetest.get_modpath("chat2") then
			chat2.send_message(minetest.get_player_by_name(player), S("You cannot teleport to a location outside the map!"), 0xFFFFFF)
		end
		return
	end
	tp.tpc_teleport_player(player)
end

-- Evade
function tp.tpe(player)
	if minetest.get_modpath("chat2") then
		chat2.send_message(minetest.get_player_by_name(player), S("EVADE!"), 0xFFFFFF)
	end
	minetest.chat_send_player(player, S("EVADE!"))
	local mindistance = 15
	local maxdistance = 50
	local times = math.random(6,20) -- how many times to jump - minimum,maximum
	local negatives = { '-','' } -- either it's this way or that way: the difference between -10 and 10
	local options = { 'x', 'y', 'z' }
	local isnegative = ''
	local distance = 0
	local axis = ''
	local iteration = 0
	for i = 1,times do
		-- do this every 1 second
		minetest.after(iteration,
			function() 
				isnegative = negatives[math.random(2)] -- choose randomly whether this is this way or that
				distance = isnegative .. math.random(mindistance,maxdistance) -- the distance to jump
				axis = options[math.random(3)]
				local command = axis .. " " .. distance
				tp.tpj(player, command)
			end
		)
		iteration = iteration + 0.5
	end
end

-- Register chatcommands
if tp.enable_tpp_command then
	minetest.register_chatcommand("tpp", {
		description = S("Teleport to a place (i.e., spawn, shop)."),
		params = S("<place> | leave empty to see available places"),
		privs = {},
		func = function(player, param)
			local pname = minetest.get_player_by_name(player)
			
			-- Show the available places to the player (taken from shivajiva101's POI mod, thanks!).
			if param == "" then
			    local places = {}
				if not tp.available_places then tp.available_places = {} end
				for key, value in pairs(tp.available_places) do
					if minetest.get_modpath("chat2") then
						chat2.send_message(minetest.get_player_by_name(player), key, 0xFFFFFF)
					end
					table.insert(places, key)
				end
				if #places == 0 then
					if minetest.get_modpath("chat2") then
						chat2.send_message(minetest.get_player_by_name(player), S("There are no places yet."), 0xFFFFFF)
					end
					return true, S("There are no places yet.")
				end
					if minetest.get_modpath("chat2") then
						chat2.send_message(minetest.get_player_by_name(player), S("Usage: /tpp <place>"), 0xFFFFFF)
					end
					table.insert(places, S("Usage: /tpp <place>"))
					return true, table.concat(places, "\n")
			-- Teleport player to the specified place (taken from shivajiva101's POI mod, thanks!).
			elseif tp.available_places[param] then
				pos = {x = tp.available_places[param].x, y = tp.available_places[param].y, z = tp.available_places[param].z}
				tp.tpp_teleport_player(player)
				minetest.chat_send_player(player, S("Teleporting to @1.", param))
				if minetest.get_modpath("chat2") then
					chat2.send_message(minetest.get_player_by_name(player), S("Teleporting to @1.", param), 0xFFFFFF)
				end	
			-- Check if the place exists.	
			elseif not tp.available_places[param] then
				minetest.chat_send_player(player, S("There is no place by that name. Keep in mind this is case-sensitive."))
				if minetest.get_modpath("chat2") then
					chat2.send_message(minetest.get_player_by_name(player), S("There is no place by that name. Keep in mind this is case-sensitive."), 0xFFFFFF)
				end	
			    return	
			end
		end,
	})
end

minetest.register_chatcommand("tpr", {
	description = S("Request teleport to another player"),
	params = S("<playername> | leave playername empty to see help message"),
	privs = {interact = true, tp = true},
	func = tp.tpr_send
})

minetest.register_chatcommand("tphr", {
	description = S("Request player to teleport to you"),
	params = S("<playername> | leave playername empty to see help message"),
	privs = {interact = true, tp = true},
	func = tp.tphr_send
})

minetest.register_chatcommand("tpc", {
	description = S("Teleport to coordinates"),
	params = S("<coordinates> | leave coordinates empty to see help message"),
	privs = {interact = true, tp_tpc = true, tp = true},
	func = tp.tpc_send
})

minetest.register_chatcommand("tpj", {
	description = S("Teleport to relative position"),
	params = S("<axis> <distance> | leave empty to see help message"),
	privs = {interact = true, tp_tpc = true, tp = true},
	func = tp.tpj
})

minetest.register_chatcommand("tpe", {
	description = S("Evade Enemy"),
	privs = {interact = true, tp_tpc = true, tp = true},
	func = tp.tpe
})

minetest.register_chatcommand("tpy", {
	description = S("Accept teleport requests from another player"),
	privs = {interact = true, tp = true},
	func = tp.tpr_accept
})

minetest.register_chatcommand("tpn", {
	description = S("Deny teleport requests from another player"),
	privs = {interact = true, tp = true},
	func = tp.tpr_deny
})

-- Log
if minetest.settings:get_bool("log_mods") then
	minetest.log("action", S("[Teleport Request] TPS Teleport v@1 Loaded!", tp.version))
end
