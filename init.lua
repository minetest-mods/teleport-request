-- Originally Teleport Request by Traxie21 and released with the WTFPL license
-- https://forum.minetest.net/viewtopic.php?id=4457
-- Updates by Zeno and ChaosWormz
-- New release by RobbieF under new mod: tps_teleport - http://blog.minetest.tv/teleport-request/

local timeout_delay = 60

local version = "1.4"

local tpr_list = {}
local tphr_list = {}

minetest.register_privilege("tp_admin", {
	description = "Admin overrides for tps_teleport.",
	give_to_singleplayer=false
})
minetest.register_privilege("tp_tpc", {
	description = "Allow player to teleport to coordinates (if permitted by area protection).",
	give_to_singleplayer=true
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

--Teleport Request System
local function tpr_send(sender, receiver)
	if receiver == "" then
		minetest.chat_send_player(sender, "Usage: /tpr <Player name>")
		return
	end

	if not minetest.get_player_by_name(receiver) then
		minetest.chat_send_player(sender, "There is no player by that name. Keep in mind this is case sensitive, and the player must be online.")
		return
	end

	minetest.chat_send_player(receiver, sender ..' is requesting to teleport to you. /tpy to accept.')
	minetest.chat_send_player(sender, 'Teleport request sent! It will time out in '.. timeout_delay ..' seconds.')

	--Write name values to list and clear old values.
	tpr_list[receiver] = sender
	--Teleport timeout delay
	minetest.after(timeout_delay, function(name)
		if tpr_list[name] then
			tpr_list[name] = nil
		end
	end, sender)
end

local function tphr_send(sender, receiver)
	if receiver == "" then
		minetest.chat_send_player(sender, "Usage: /tphr <Player name>")
		return
	end

	if not minetest.get_player_by_name(receiver) then
		minetest.chat_send_player(sender, "There is no player by that name. Keep in mind this is case sensitive, and the player must be online.")
		return
	end

	minetest.chat_send_player(receiver, sender ..' is requesting that you teleport to them. /tpy to accept; /tpn to deny')
	minetest.chat_send_player(sender, 'Teleport request sent! It will time out in '.. timeout_delay ..' seconds.')

	--Write name values to list and clear old values.
	tphr_list[receiver] = sender
	--Teleport timeout delay
	minetest.after(timeout_delay, function(name)
		if tphr_list[name] then
			tphr_list[name] = nil
		end
	end, sender)
end

local function tpc_send(player,coordinates)

	local posx,posy,posz = string.match(coordinates, "^(-?%d+),(-?%d+),(-?%d+)$")
	local pname = minetest.get_player_by_name(player)

	if posx ~= nil or posy ~= nil or posz ~= nil then
	  posx = tonumber(posx) + 0.0
	  posy = tonumber(posy) + 0.0
	  posz = tonumber(posz) + 0.0
	end

	if posx==nil or posy==nil or posz==nil or string.len(posx) > 6 or string.len(posy) > 6 or string.len(posz) > 6 then
		minetest.chat_send_player(player, "Usage: /tpc <x,y,z>")
		return nil
	end
	
	if posx > 32765 or posx < -32765 or posy > 32765 or posy < -32765 or posz > 32765 or posz < -32765 then
		minetest.chat_send_player(player, "Error: Invalid coordinates.")
		return nil
	end

	local target_coords={x=posx, y=posy, z=posz}

	-- If the area is protected, reject the user's request to teleport to these coordinates
	-- In future release we'll actually query the player who owns the area, if they're online, and ask for their permission.
	-- Admin user (priv "tp_admin") overrides all protection
	if minetest.check_player_privs(pname, {tp_admin=true}) then
		minetest.chat_send_player(player, 'Teleporting to '..posx..','..posy..','..posz)
		pname:setpos(find_free_position_near(target_coords))
		minetest.sound_play("whoosh", {pos = target_coords, gain = 0.5, max_hear_distance = 10})
		parti2(target_coords)
	else
		if minetest.check_player_privs(pname, {tp_tpc=true}) then
			local protected = minetest.is_protected(target_coords,pname)
			if protected then
				if not areas:canInteract(target_coords, player) then
					local owners = areas:getNodeOwners(target_coords)
					minetest.chat_send_player(player,("Error: %s is protected by %s."):format(minetest.pos_to_string(target_coords),table.concat(owners, ", ")))
					return
				end
			end
			minetest.chat_send_player(player, 'Teleporting to '..posx..','..posy..','..posz)
			pname:setpos(find_free_position_near(target_coords))
			minetest.sound_play("whoosh", {pos = target_coords, gain = 0.5, max_hear_distance = 10})
			parti2(target_coords)
		else
			minetest.chat_send_player(player, "Error: You do not have permission to teleport to coordinates.")	
			return
		end
	end
end

local function tpr_deny(name)
	if tpr_list[name] then
		minetest.chat_send_player(tpr_list[name], 'Teleport request denied.')
		tpr_list[name] = nil
	end
	if tphr_list[name] then
		minetest.chat_send_player(tphr_list[name], 'Teleport request denied.')
		tphr_list[name] = nil
	end
end

--Teleport Accept Systems
local function tpr_accept(name, param)

	--Check to prevent constant teleporting.
	if not tpr_list[name]
	and not tphr_list[name] then
		minetest.chat_send_player(name, "Usage: /tpy allows you to accept teleport requests sent to you by other players.")
		return
	end

	local chatmsg, source, target, name2

	if tpr_list[name] then
		name2 = tpr_list[name]
		source = minetest.get_player_by_name(name)
		target = minetest.get_player_by_name(name2)
		chatmsg = name2 .. " is teleporting to you."
		tpr_list[name] = nil
	elseif tphr_list[name] then
		name2 = tphr_list[name]
		source = minetest.get_player_by_name(name2)
		target = minetest.get_player_by_name(name)
		chatmsg = "You are teleporting to " .. name2 .. "."
		tphr_list[name] = nil
	else
		return
	end

	-- Could happen if either player disconnects (or timeout); if so just abort
	if not source
	or not target then
		return
	end

	minetest.chat_send_player(name2, "Request Accepted!")
	minetest.chat_send_player(name, chatmsg)
	
	local target_coords=source:getpos()
	target:setpos(find_free_position_near(target_coords))
	minetest.sound_play("whoosh", {pos = target_coords, gain = 0.5, max_hear_distance = 10})
	parti2(target_coords)
end

-- Teleport Jump - Relative Position Teleportation by number of nodes
local function tpj(player,param)
	local pname = minetest.get_player_by_name(player)
	
	if param == "" then
		minetest.chat_send_player(player, "Usage. <X|Y|Z> <Number>")
		return false
	end
	
	local args = param:split(" ")
	if #args < 2 then
		minetest.chat_send_player(player, "Usage. <X|Y|Z> <Number>")
		return false
	end
	
	if not tonumber(args[2]) then
		return false, "Not a Number!"
	end
	
	-- Initially generate the target coords from the player's current position (since it's relative) and then perform the math.
	local target_coords = minetest.get_player_by_name(player):getpos()
	if args[1] == "x" then
		target_coords["x"] = target_coords["x"] + tonumber(args[2])
		pname:setpos(find_free_position_near(target_coords))
		minetest.sound_play("whoosh", {pos = target_coords, gain = 0.5, max_hear_distance = 10})
		parti2(target_coords)
	elseif args[1] == "y" then
		target_coords["y"] = target_coords["y"] + tonumber(args[2])
		pname:setpos(find_free_position_near(target_coords))
		minetest.sound_play("whoosh", {pos = target_coords, gain = 0.5, max_hear_distance = 10})
		parti2(target_coords)
	elseif args[1] == "z" then
		target_coords["z"] = target_coords["z"] + tonumber(args[2])
		pname:setpos(find_free_position_near(target_coords))
		minetest.sound_play("whoosh", {pos = target_coords, gain = 0.5, max_hear_distance = 10})
		parti2(target_coords)
	else
		minetest.chat_send_player(player,"Not a valid axis. Valid options are X, Y or Z.")
	end
end

-- Evade
local function tpe(player)
	local negatives = { '-','' } -- either it's this way or that way
	local isnegative = negatives[math.random(2)]
	local distance = isnegative .. math.random(4,15) -- the distance to jump
	local times = math.random(3,6) -- how many times to jump - minimum,maximum
	local options = { 'x', 'y', 'z' }
	local axis = options[math.random(3)]
	for i = 1,times do
		minetest.after(1, function() tpj(axis,distance) end) -- do this every 1 second
	end
end

minetest.register_chatcommand("tpr", {
	description = "Request teleport to another player",
	params = "<playername> | leave playername empty to see help message",
	privs = {interact=true},
	func = tpr_send
})

minetest.register_chatcommand("tphr", {
	description = "Request player to teleport to you",
	params = "<playername> | leave playername empty to see help message",
	privs = {interact=true},
	func = tphr_send
})

minetest.register_chatcommand("tpc", {
	description = "Teleport to coordinates",
	params = "<coordinates> | leave coordinates empty to see help message",
	privs = {interact=true,tp_tpc=true},
	func = tpc_send
})

minetest.register_chatcommand("tpj", {
	description = "Teleport to relative position",
	params = "<axis> <distance> | leave empty to see help message",
	privs = {interact=true},
	func = tpj
})

minetest.register_chatcommand("tpe", {
	description = "Evade Enemy",
	privs = {interact=true},
	func = tpe
})

minetest.register_chatcommand("tpy", {
	description = "Accept teleport requests from another player",
	func = tpr_accept
})

minetest.register_chatcommand("tpn", {
	description = "Deny teleport requests from another player",
	func = tpr_deny
})

minetest.log("info", "[Teleport Request] TPS Teleport v" .. version .. " Loaded.")
