
local timeout_delay = 60

-- Set to true to register tpr_admin priv
local regnewpriv = false

local version = "0.2"

local tpr_list = {}
local tphr_list = {}

--DO NOT CHANGE:------------
value_carryover = nil
value_carryover2 = nil
----------------------------

-- Reset after configured delay.
-- These functions cannot be local (not sure if this can be avoided)
function reset_request(name)
	if tpr_list[value_carryover] ~= nil then
		tpr_list[value_carryover] = nil
	end
end

function reset_request2(name)
	if tphr_list[value_carryover2] ~= nil then
		tphr_list[value_carryover2] = nil
	end
end

--Teleport Request System
local function tpr_send(name, param)

	local sender = name
	local receiver = param

	value_carryover = param

	if receiver == "" then
		minetest.chat_send_player(sender, "Usage: /tpr <Player name>")
		return
	end

	--If paremeter is valid, Send teleport message and set the table.
	if minetest.env:get_player_by_name(receiver) then
		minetest.chat_send_player(receiver, sender ..' is requesting to teleport to you. /tpy to accept.')
		minetest.chat_send_player(sender, 'Teleport request sent! It will time out in '.. timeout_delay ..' seconds.')

		--Write name values to list and clear old values.
		tpr_list[receiver] = nil
		tpr_list[receiver] = sender
		--Teleport timeout delay
		minetest.after(timeout_delay, reset_request)
	end
end

local function tphr_send(name, param)

	local sender = name
	local receiver = param

	value_carryover = param

	if receiver == "" then
		minetest.chat_send_player(sender, "Usage: /tphr <Player name>")
		return
	end

	--If paremeter is valid, Send teleport message and set the table.
	if minetest.env:get_player_by_name(receiver) then
		minetest.chat_send_player(receiver, sender ..' is requesting that you teleport to them. /tpy to accept.')
		minetest.chat_send_player(sender, 'Teleport request sent! It will time out in '.. timeout_delay ..' seconds.')

		--Write name values to list and clear old values.
		tphr_list[receiver] = nil
		tphr_list[receiver] = sender
		--Teleport timeout delay
		minetest.after(timeout_delay, reset_request2)
	end
end

local function tpr_deny(name)
	sender = tpr_list[value_carryover]
	if tpr_list[value_carryover] ~= nil then
		tpr_list[value_carryover] = nil
		minetest.chat_send_player(sender, 'Teleport request denied.')
	end
	sender2 = tphr_list[value_carryover2]
	if tphr_list[value_carryover2] ~= nil then
		tphr_list[value_carryover2] = nil
		minetest.chat_send_player(sender2, 'Teleport request denied.')
	end
end

-- Copied from Celeron-55's /teleport command. Thanks Celeron!
local function find_free_position_near(pos)
	local tries = {
		{x=1,y=0,z=0},
		{x=-1,y=0,z=0},
		{x=0,y=0,z=1},
		{x=0,y=0,z=-1},
	}
	for _, d in ipairs(tries) do
		local p = {x = pos.x+d.x, y = pos.y+d.y, z = pos.z+d.z}
		local n = minetest.env:get_node(p)
		if not minetest.registered_nodes[n.name].walkable then
			return p, true
		end
	end
	return pos, false
end


--Teleport Accept Systems
local function tpr_accept(name, param)

	--Check to prevent constant teleporting.
	if tpr_list[name] == nil and tphr_list[name] == nil then
		minetest.chat_send_player(name, "Usage: /tpy allows you to accept teleport requests sent to you by other players")
		return
	end

	local chatmsg
	local source = nil
	local target = nil
	local name2

	if tpr_list[name] then
		name2 = tpr_list[name]
		source = minetest.env:get_player_by_name(name)
		target = minetest.env:get_player_by_name(name2)
		chatmsg = name2 .. " is teleporting to you."
		tpr_list[name] = nil
	elseif tphr_list[name] then
		name2 = tphr_list[name]
		source = minetest.env:get_player_by_name(name2)
		target = minetest.env:get_player_by_name(name)
		chatmsg = "You are teleporting to " .. name2 .. "."
		tphr_list[name] = nil
	else
		return
	end

	-- Could happen if either player disconnects (or timeout); if so just abort
	if source == nil or target == nil then
		return
	end

	minetest.chat_send_player(name2, "Request Accepted!")
	minetest.chat_send_player(name, chatmsg)

	p = source:getpos()
	p = find_free_position_near(p)
	target:setpos(p)
end

--Initalize Permissions.

if regnewpriv then
	minetest.register_privilege("tpr_admin", {
		description = "Permission to override teleport to other players. UNFINISHED",
		give_to_singleplayer = true
	})
end

--Initalize Commands.

minetest.register_chatcommand("tpr", {
	description = "Request teleport to another player",
	params = "<playername> | leave playername empty to see help message",
	privs = {interact=true},
	func = tpr_send

})

minetest.register_chatcommand("tphr", {
	description = "Request teleport to another player",
	params = "<playername> | leave playername empty to see help message",
	privs = {interact=true},
	func = tphr_send

})

minetest.register_chatcommand("tpy", {
	description = "Accept teleport requests from another player",
	func = tpr_accept
})

minetest.register_chatcommand("tpn", {
	description = "Deny teleport requests from another player",
	func = tpr_deny
})

print ("[Teleport Request] Teleport Request v" .. version .. " Loaded.")
