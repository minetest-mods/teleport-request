[The Pixel Shadow](https://minetest.tv/) game servers have switched "teleport" to "teleport request" which means players must literally request from a player to teleport to them before they will be allowed to do so. This prevents malicious users from teleporting to players' private areas where they are working and causing grief, or stealing items from locked chests. It also enhances the overall privacy of our services since if denied teleport, a player must instead travel to the area and "use the front door" so to speak... which might be a locked iron door.

##Usage:

``` /tpr [playername] ```
Requests permission to teleport to another player, where [playername] is their exact name.

``` /tphr [playername] ```
Request permission to teleport another player to you.

``` /tpy ```
Accept a user's request to teleport to you or teleport you to them.

``` /tpn ```
Deny a user's request to teleport to youor teleport you to them.

##Features To Come
``` /tpc [x,y,z] ```
Teleport to coordinates. Honors area protection.
