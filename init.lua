--[[
Copyright (C) 2015-2019  Michael Tomaino (PlatinumArts@gmail.com)

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
License: LGPL-2.1 for code, CC-BY-SA-4.0 for media and textures.

Optional dependencies: areas, intllib
New release by RobbieF under new mod: tps_teleport - http://blog.minetest.tv/teleport-request/
--]]

-- Enable configuration
enable_configuration = false

-- Load support for intllib.
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

-- Load configuration.
if enable_configuration then
	dofile(MP.."/config.lua")
end

local timeout_delay = 60

local version = "1.5"

local tpr_list = {}
local tphr_list = {}

local map_size = 30912
local function can_teleport(to)
   return to.x < map_size and to.x > -map_size and to.y < map_size and to.y > -map_size and to.z < map_size and to.z > -map_size
end

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
	give_to_singleplayer = true,
	give_to_admin = true,
})

local function find_free_position_near(pos)
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

local function parti(pos)
	minetest.add_particlespawner(50, 0.4,
		{x=pos.x + 0.5, y=pos.y, z=pos.z + 0.5}, {x=pos.x - 0.5, y=pos.y, z=pos.z - 0.5},
		{x=0, y=5, z=0}, {x=0, y=0, z=0},
		{x=0, y=5, z=0}, {x=0, y=0, z=0},
		3, 5,
		3, 5,
		false,
		"tps_portal_parti.png")
end

local function parti2(pos)
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
function tpr_send(sender, receiver)
	if minetest.check_player_privs(sender, {tp_admin = true}) then
			-- Write name values to list and clear old values.
				tpr_list[receiver] = sender
			-- Teleport timeout delay
				minetest.after(timeout_delay, function(name)
			if tpr_list[name] then
			tpr_list[name] = nil
		end
	end, sender)
	if receiver == "" then
		minetest.chat_send_player(sender, S("Usage: /tpr <Player name>"))
            return	
	end
	if not minetest.get_player_by_name(receiver) then
		minetest.chat_send_player(sender, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online"))
	    return
	end
	tpr_accept(receiver)
			minetest.chat_send_player(sender, S("You are teleporting to @1.", receiver))
		return
	end
	
	if receiver == "" then
		minetest.chat_send_player(sender, S("Usage: /tpr <Player name>"))
		return
	end

	if not minetest.get_player_by_name(receiver) then
		minetest.chat_send_player(sender, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online."))
		return
	end

	minetest.chat_send_player(receiver, S("@1 is requesting to teleport to you. /tpy to accept", sender))
	minetest.chat_send_player(sender, S("Teleport request sent! It will timeout in @1 seconds", timeout_delay))

	-- Write name values to list and clear old values.
	if not minetest.check_player_privs(sender, {tp_admin = true}) then
	tpr_list[receiver] = sender
	-- Teleport timeout delay
	minetest.after(timeout_delay, function(name)
		if tpr_list[name] then
			tpr_list[name] = nil
		end
	end, sender)
	end	
end

function tphr_send(sender, receiver)
	if minetest.check_player_privs(sender, {tp_admin = true}) then
	-- Write name values to list and clear old values.
		tphr_list[receiver] = sender
	-- Teleport timeout delay
		minetest.after(timeout_delay, function(name)
	if tphr_list[name] then
		tphr_list[name] = nil
		end
	end, sender)
	if receiver == "" then
		minetest.chat_send_player(sender, S("Usage: /tphr <Player name>"))
	    return	
	end
	if not minetest.get_player_by_name(receiver) then
		minetest.chat_send_player(sender, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online"))
	    return
	end
	tpr_accept(receiver)
		minetest.chat_send_player(sender, S("@1 is teleporting to you.", receiver))
		return
	end
	if receiver == "" then
	minetest.chat_send_player(sender, S("Usage: /tphr <Player name>"))
		return
	end

	if not minetest.get_player_by_name(receiver) then
		minetest.chat_send_player(sender, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online."))
		return
	end

	minetest.chat_send_player(receiver, S("@1 is requesting that you teleport to them. /tpy to accept; /tpn to deny", sender))
	minetest.chat_send_player(sender, S("Teleport request sent! It will timeout in @1 seconds ", timeout_delay))

	-- Write name values to list and clear old values.
	if not minetest.check_player_privs(sender, {tp_admin = true}) then
	tphr_list[receiver] = sender
	-- Teleport timeout delay
	minetest.after(timeout_delay, function(name)
		if tphr_list[name] then
			tphr_list[name] = nil
		end
	end, sender)
	end
end

function tpc_send(player, coordinates)

	local posx,posy,posz = string.match(coordinates, "^(-?%d+), (-?%d+), (-?%d+)$")
	local pname = minetest.get_player_by_name(player)

	if posx ~= nil or posy ~= nil or posz ~= nil then
	  posx = tonumber(posx) + 0.0
	  posy = tonumber(posy) + 0.0
	  posz = tonumber(posz) + 0.0
	end

	if posx==nil or posy==nil or posz==nil or string.len(posx) > 6 or string.len(posy) > 6 or string.len(posz) > 6 then
		minetest.chat_send_player(player, S("Usage: /tpc <x, y, z>"))
		return nil
	end

	local target_coords = {x=posx, y=posy, z=posz}

	if can_teleport(target_coords) == false then
		minetest.chat_send_player(player, S("You cannot teleport to a location outside the map!"))
		return nil
	end

	-- If the area is protected, reject the user's request to teleport to these coordinates
	-- In future release we'll actually query the player who owns the area, if they're online, and ask for their permission.
	-- Admin user (priv "tp_admin") overrides all protection
	if minetest.check_player_privs(pname, {tp_admin=true}) then
		minetest.chat_send_player(player, S("Teleporting to: @1, @2, @3", posx, posy, posz))
		pname:set_pos(find_free_position_near(target_coords))
		minetest.sound_play("whoosh", {pos = target_coords, gain = 0.5, max_hear_distance = 10})
		--parti2(target_coords)
	else
		if minetest.check_player_privs(pname, {tp_tpc = true}) then
			local protected = minetest.is_protected(target_coords,pname)
			if protected and minetest.get_modpath("areas") then
				if not areas:canInteract(target_coords, player) then
					local owners = areas:getNodeOwners(target_coords)
					minetest.chat_send_player(player, S("Error: @1 is protected by @2.", minetest.pos_to_string(target_coords), table.concat(owners, ", ")))
					return
				end
			end
			minetest.chat_send_player(player, S("Teleporting to: @1, @2, @3", posx, posy, posz))
			pname:set_pos(find_free_position_near(target_coords))
			minetest.sound_play("whoosh", {pos = target_coords, gain = 0.5, max_hear_distance = 10})
			--parti2(target_coords)
		else
			minetest.chat_send_player(player, S("Error: You do not have permission to teleport to coordinates."))
			return
		end
	end
end

function tpr_deny(name)
	if tpr_list[name] then
		minetest.chat_send_player(tpr_list[name], S("Teleport request denied."))
		tpr_list[name] = nil
	end
	if tphr_list[name] then
		minetest.chat_send_player(tphr_list[name], S("Teleport request denied."))
		tphr_list[name] = nil
	end
end

-- Teleport Accept Systems
function tpr_accept(name, param)
	-- Check to prevent constant teleporting.
	if not tpr_list[name]
	and not tphr_list[name] then
		minetest.chat_send_player(name, S("Usage: /tpy allows you to accept teleport requests sent to you by other players"))
		return
	end

	local chatmsg, source, target, name2

	if tpr_list[name] then
		name2 = tpr_list[name]
		source = minetest.get_player_by_name(name)
		target = minetest.get_player_by_name(name2)
		chatmsg = S("@1 is teleporting to you.", name2)
		tpr_list[name] = nil
	elseif tphr_list[name] then
		name2 = tphr_list[name]
		source = minetest.get_player_by_name(name2)
		target = minetest.get_player_by_name(name)
		chatmsg = S("You are teleporting to @1.", name2)
		tphr_list[name] = nil
	else
		return
	end

	-- Could happen if either player disconnects (or timeout); if so just abort
	if not source
	or not target then
		return
	end

	minetest.chat_send_player(name2, S("Request Accepted!"))
	minetest.chat_send_player(name, chatmsg)
	
	local target_coords = source:get_pos()
	target:set_pos(find_free_position_near(target_coords))
	minetest.sound_play("whoosh", {pos = target_coords, gain = 0.5, max_hear_distance = 10})
	--parti2(target_coords)
end

-- Teleport Jump - Relative Position Teleportation by number of nodes
function tpj(player, param)
	local pname = minetest.get_player_by_name(player)

	if param == "" then
		minetest.chat_send_player(player, S("Usage: <x|y|z> <Number>"))
		return false
	end

	local args = param:split(" ") -- look into this. Can it crash if the player does not have two parameters?
	if #args < 2 then
		minetest.chat_send_player(player, S("Usage: <x|y|z> <Number>"))
		return false
	end
	
	if not tonumber(args[2]) then
		return false, "Not a Number!"
	end
	
	-- Initially generate the target coords from the player's current position (since it's relative) and then perform the math.
	local target_coords = minetest.get_player_by_name(player):get_pos()
	if args[1] == "x" then
		target_coords["x"] = target_coords["x"] + tonumber(args[2])
	elseif args[1] == "y" then
		target_coords["y"] = target_coords["y"] + tonumber(args[2])
	elseif args[1] == "z" then
		target_coords["z"] = target_coords["z"] + tonumber(args[2])
	else
		minetest.chat_send_player(player, S("Not a valid axis. Valid options are X, Y or Z."))
		return
	end
	if can_teleport(target_coords) == false then
		minetest.chat_send_player(player, S("You cannot teleport to a location outside the map!"))
		return
	end
	pname:set_pos(find_free_position_near(target_coords))
	minetest.sound_play("whoosh", {pos = target_coords, gain = 0.5, max_hear_distance = 10})
	--parti2(target_coords)
end

-- Evade
function tpe(player)
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
				tpj(player,command)
			end
		)
		iteration = iteration + 0.5
	end
end

-- Register chatcommands
if enable_configuration then
	minetest.register_chatcommand("tpp", {
		description = S("Teleport to a place (i.e., spawn, shop)."),
		params = S("<place> | leave empty to see available places"),
		privs = {},
		func = function(player, param)
			local pname = minetest.get_player_by_name(player)
			param = param:lower()
			
			-- Show the available places to the player (taken from shivajiva101's POI mod, thanks!).
			if param == "" then
			    local places = {}
				for key, value in pairs(available_places) do
					table.insert(places, key)
				end
				if #places == 0 then
					return true, S("There are no places yet.")
				end
					table.insert(places, S("Usage: /tpp <place>"))
					return true, table.concat(places, "\n")
				
			-- Teleport player to the specified place (taken from shivajiva101's POI mod, thanks!).
			elseif available_places[param] then
				local pos = {x = available_places[param].x, y = available_places[param].y, z = available_places[param].z}
				pname:set_pos(pos)
				minetest.chat_send_player(player, S("Teleporting to @1.", param))
			-- Check if the place exists.	
			elseif not available_places[param] then
				minetest.chat_send_player(player, S("There is no place by that name. Keep in mind this is case-sensitive."))
			end
		end,
	})
end

minetest.register_chatcommand("tpr", {
	description = S("Request teleport to another player"),
	params = S("<playername> | leave playername empty to see help message"),
	privs = {interact = true, tp = true},
	func = tpr_send
})

minetest.register_chatcommand("tphr", {
	description = S("Request player to teleport to you"),
	params = S("<playername> | leave playername empty to see help message"),
	privs = {interact = true, tp = true},
	func = tphr_send
})

minetest.register_chatcommand("tpc", {
	description = S("Teleport to coordinates"),
	params = S("<coordinates> | leave coordinates empty to see help message"),
	privs = {interact = true, tp_tpc = true, tp = true},
	func = tpc_send
})

minetest.register_chatcommand("tpj", {
	description = S("Teleport to relative position"),
	params = S("<axis> <distance> | leave empty to see help message"),
	privs = {interact = true, tp_tpc = true, tp = true},
	func = tpj
})

minetest.register_chatcommand("tpe", {
	description = S("Evade Enemy"),
	privs = {interact = true, tp_tpc = true, tp = true},
	func = tpe
})

minetest.register_chatcommand("tpy", {
	description = S("Accept teleport requests from another player"),
	privs = {interact = true, tp = true},
	func = tpr_accept
})

minetest.register_chatcommand("tpn", {
	description = S("Deny teleport requests from another player"),
	privs = {interact = true, tp = true},
	func = tpr_deny
})

-- Log
if minetest.settings:get_bool("log_mods") then
	minetest.log("action", S("[Teleport Request] TPS Teleport v@1 Loaded!", version))
end
