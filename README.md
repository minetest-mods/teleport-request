##*tps_teleport* is a mod for Minetest game servers.

##Description:
[The Pixel Shadow](https://minetest.tv/) Minetest game servers have switched from "teleport" to "teleport request" via the *tps_teleport* mod. This mod makes it so players must send a request to another player in order to teleport to them. Before they will be allowed to do so, the player must accept the request. This prevents malicious users from teleporting to players' private areas without their permission. It also enhances the overall privacy of our services since if denied teleport, a player must instead travel to the area and "use the front door" so to speak... which might be a locked iron door.

##Privileges:
- **interact** Permits use of /tpr and /tphr
- **tp_tpc** Permits use of /tpc
- **tp_admin** Admin priv allows admin to teleport anywhere without permission

Players may also teleport to coordinates, however if the area is protected, the teleport will be denied.

##Usage:

``` /tpr [playername] ```
- **Name:** Teleport Request
- **Description:** Requests permission to teleport to another player, where [playername] is their exact name.
- **Required Privilege:** interact
- **Example Usage:** */tpr RobbieF* - requests permission from RobbieF to teleport to them.
- **Notes:** Usernames are case-sensitive.

``` /tphr [playername] ```
- **Name:** Teleport Here Request
- **Description:** Request permission to teleport another player to you.
- **Required Privilege:** interact
- **Example Usage:** /tphr RobbieF - requests RobbieF to teleport to you.
- **Notes:** Usernames are case-sensitive.

``` /tpc [x,y,z] ```
- **Name:** Teleport to Coordinates
- **Description:** Teleport to coordinates.
- **Required Privilege:** interact, tp_tpc
- **Notes:** Honors area protection: if the area is protected, it must be owned by you in order to teleport to it.

``` /tpj [axis] [distance] ```
- **Name:** Teleport Jump
- **Description:** Teleport a specified distance along a single specified axis.
- **Required Privilege:** interact
- **Available Options for *axis*:** x, y, z
- **Example Usage:** '/tpj y 10' - teleport 10 nodes into the air.

``` /tpe ```
- **Name:** Teleport Evade
- **Description:** In a sticky situation? Evade your enemy by teleporting to several nearby coordinates in random pattern. There's no knowing where you'll end up.
- **Required Privilege:** interact
- **Example Usage:** '/tpe' - teleports you to a random number of random coordinates in an evasive pattern.

``` /tpy ```
- **Description:** Accept a user's request to teleport to you or teleport you to them.

``` /tpn ```
- **Description:** Deny a user's request to teleport to youor teleport you to them.

###Please Note:
Players with the 'tp_admin' privilege override all the required privileges above, except 'interact'.

##Contributors:
- [RobbieF](https://minetest.tv) | [GitHub](https://github.com/Cat5TV)
- [DonBatman](https://github.com/donbatman)
- [NathanS21](http://nathansalapat.com/)
- [ChaosWormz](https://github.com/ChaosWormz)
- [Traxie21](https://github.com/Traxie21) The original creater of this mod
- All those who contributed to the original mod (please see init.lua)

##To Do:
- Make it so if a player attempts to teleport to coordinates within a protected area owned by another player, and that player is online, the owner receives a request to allow or deny the user from teleporting to their area.
- Add limitations to /tpc which only allow a user to teleport X number of blocks. Prevents users from teleporting to the edge of the world.
- Make it so tp_admin priv also overrides need for player to accept /tpr or /tphr
- Assess value in changing all tpr-based chat commands to one global command such as /tp to reduce the chance of confusion between tps_admin and the original mod (and also make it so people don't have to remember so many commands).
- Create a better sound effect for teleport and apply it to all teleport methods (not just /tpc)
- Add a handful of coordinates which can be set in config and teleported to by anyone regardless of their protection status (eg., Spawn).
- Add a privilege which is required in order to use all commands. I haven't added such a thing since it hasn't been needed on our servers, but I imagine it would be useful on other servers who desire to grant these features only to specific players.
- Create a new function for the actual setpos() to remove all the redundant code each time the player is moved and the sound played.
- Rewrite to place all chat commands into one single command much like how /teleport works.
- Add a [different] sound effect at the source coords when a TP takes place (so other players hear it when to teleport away).
- Make evade respect land: no teleporting inside land, but instead make sure player is standing on surface or in water.
