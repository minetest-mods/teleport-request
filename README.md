##*tps_teleport* is a mod for Minetest game servers.

##Description:
[The Pixel Shadow](https://minetest.tv/) Minetest game servers have switched from "teleport" to "teleport request" via the *tps_teleport* mod. This mod makes it so players must send a request to another player in order to teleport to them. Before they will be allowed to do so, the player must accept the request. This prevents malicious users from teleporting to players' private areas without their permission. It also enhances the overall privacy of our services since if denied teleport, a player must instead travel to the area and "use the front door" so to speak... which might be a locked iron door.

Players may also teleport to coordinates, however if the area is protected, the teleport will be denied.

##Usage:

``` /tpr [playername] ```
Requests permission to teleport to another player, where [playername] is their exact name.

``` /tphr [playername] ```
Request permission to teleport another player to you.

``` /tpc [x,y,z] ```
Teleport to coordinates. Honors area protection: if the area is protected, it must be owned by you in order to teleport to it.

``` /tpy ```
Accept a user's request to teleport to you or teleport you to them.

``` /tpn ```
Deny a user's request to teleport to youor teleport you to them.

##To Do:
- Make it so if a player attempts to teleport to coordinates within a protected area owned by another player, and that player is online, the owner receives a request to allow or deny the user from teleporting to their area.
- Add limitations to /tpc which only allow a user to teleport X number of blocks. Prevents users from teleporting to the edge of the world.
