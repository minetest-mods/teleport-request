--Configuration values:
--Use these to customize this mod
timeout_delay = 60

--DO NOT CHANGE:

value_carryover = nil
value_carryover2 = nil


print ("[Teleport Request] Teleport Request v0.1a Loaded.")

--Teleport Request System

local function tpr_send(name, param)

	--Register variables

    	sender = name
    	receiver = param
	value_carryover = param
	--Check for empty parameter

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

	--Register variables

    	sender2 = name
    	receiver2 = param
	value_carryover2 = param
	--Check for empty parameter

    	if receiver2 == "" then
            minetest.chat_send_player(sender2, "Usage: /tphr <Player name>")
            return
     	end

	--If paremeter is valid, Send teleport message and set the table.

    	if minetest.env:get_player_by_name(receiver2) then
            minetest.chat_send_player(receiver2, sender2 ..' is requesting that you teleport to them. /tpy to accept.')
      	minetest.chat_send_player(sender2, 'Teleport request sent! It will time out in '.. timeout_delay ..' seconds.')
	
	--Write name values to list and clear old values.
        	tphr_list[receiver2] = nil
        	tphr_list[receiver2] = sender2
		--Teleport timeout delay
		minetest.after(timeout_delay, reset_request2)
    end
end


--Reset after configured delay.

function reset_request(name)

	--A check to prevent crashing

	if tpr_list[value_carryover] ~= nil then
        	tpr_list[value_carryover] = nil

	end

end

function reset_request2(name)

	--A check to prevent crashing

	if tphr_list[value_carryover2] ~= nil then
        	tphr_list[value_carryover2] = nil

	end

end

function tpr_deny(name)
sender = tpr_list[value_carryover]
	if tpr_list[value_carryover] ~= nil then
        	tpr_list[value_carryover] = nil
		minetest.chat_send_player(sender, 'Teleport request denied :C')

	end
sender2 = tphr_list[value_carryover2]
	if tphr_list[value_carryover2] ~= nil then
        	tphr_list[value_carryover2] = nil
		minetest.chat_send_player(sender2, 'Teleport request denied :C')

	end
end
--Teleport Accept Systems

local function tpr_accept(name, param)

	--Register name variables.

	receiver = name
	sender = tpr_list[name]
	
	receiver = name
	sender2 = tphr_list[name]
	--Check to prevent constant teleporting.	

	if tpr_list[name] == nil and tphr_list[name] == nil then
            minetest.chat_send_player(name, "Usage: /tpy allows you to accept teleport requests sent to you by other players")

		return
	end
	
	--Teleport Accept system
	--Check to ensure name is valid, then send appropriate chat messages
	
	if tpr_list[name] then
		minetest.chat_send_player(tpr_list[receiver], "Request Accepted!")
		minetest.chat_send_player(receiver, sender..' is teleporting to you.')

	--Code here copied from Celeron-55's /teleport command. Thanks Celeron!

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

		--Get names from variables and set position. Then actually teleport the player.

		local requester = minetest.env:get_player_by_name(sender)
		local accepter = minetest.env:get_player_by_name(name)
		local p = nil
		p = accepter:getpos()
		p = find_free_position_near(p)
		requester:setpos(p)

		-- Set name values to nil to prevent re-teleporting on the same request.

		tpr_list[name] = nil
		return
	end
	
	--Teleport Here accepting system
	
	if tphr_list[name] then
		minetest.chat_send_player(tphr_list[receiver], "Request Accepted!")
		minetest.chat_send_player(receiver, 'you are teleporting to '..sender2..'.')

	--Code here copied from Celeron-55's /teleport command. Thanks Celeron!

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

		--Get names from variables and set position. Then actually teleport the player.

		local requester = minetest.env:get_player_by_name(sender2)
		local accepter = minetest.env:get_player_by_name(name)
		local p = nil
		p = requester:getpos()
		p = find_free_position_near(p)
		accepter:setpos(p)

		-- Set name values to nil to prevent re-teleporting on the same request.

		tphr_list[name] = nil
		return
	end
end


--Initalize Table.

tpr_list = {}
tphr_list = {}

--Initalize Permissions.

minetest.register_privilege("tpr_admin", {
    description = "Permission to override teleport to other players. UNFINISHED", 
    give_to_singleplayer = true
})

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
