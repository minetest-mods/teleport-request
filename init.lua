-- Originally Teleport Request by Traxie21 and released with the WTFPL license
-- https://forum.minetest.net/viewtopic.php?id=4457
-- Updates by Zeno and ChaosWormz
-- New release by RobbieF under new mod: tps_teleport - http://blog.minetest.tv/teleport-request/

local timeout_delay = 60

local version = "1.3"

local tpr_list = {}
local tphr_list = {}

minetest.register_privilege("tp_admin", {description = "Admin overrides for tps_teleport.", give_to_singleplayer=false,})

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

--Teleport Request System
local function tpr_send(sender, receiver)
	if receiver == "" then
		minetest.chat_send_player(sender, "Usage: /tpr <Player name>")
		return
	end

	--If paremeter is valid, Send teleport message and set the table.
	if not minetest.get_player_by_name(receiver) then
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

	--If paremeter is valid, Send teleport message and set the table.
	if not minetest.get_player_by_name(receiver) then
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

local function tpc_go(player,coordinates)
	minetest.chat_send_player(player, 'Teleporting to '..posx..','..posy..','..posz)
	minetest.sound_play("tps_portal", {pos = target_coords, gain = 1.0, max_hear_distance = 10})
	pname:setpos(find_free_position_near(target_coords))
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
		tpc_go(player,target_coords)
	else
		local protected = minetest.is_protected(target_coords,pname)
		if protected then
			if not areas:canInteract(target_coords, player) then
				local owners = areas:getNodeOwners(target_coords)
				minetest.chat_send_player(player,("Error: %s is protected by %s."):format(minetest.pos_to_string(target_coords),table.concat(owners, ", ")))
				return
			end
		end
		tpc_go(player,target_coords)
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

	target:setpos(find_free_position_near(source:getpos()))
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
	privs = {interact=true},
	func = tpc_send
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
