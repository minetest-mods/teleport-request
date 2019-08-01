# Teleport Request

[The Pixel Shadow](https://minetest.tv/) Minetest game servers have switched from "teleport" to "teleport request" via the *teleport-request* mod. This mod makes it so players must send a request to another player in order to teleport to them. Before they will be allowed to do so, the player must accept the request. This prevents malicious users from teleporting to players' private areas without their permission. It also enhances the overall privacy of our services since if denied teleport, a player must instead travel to the area and "use the front door" so to speak... which might be a locked iron door.

## Privileges:
Each command needs a privilege. These are the following privileges:
- **tp** is requiered in order to use all commands.
- **tp_tpc** is requiered in order to use `/tpc`
- **tp_tpc** is requiered in order to use `/tpe`
- **tp_tpc** is requiered in order to use `/tpj`
- **interact** is also requiered to use all commands.    
**tp_admin** overrides everything: e.g. you can teleport to players even when they haven't decided to accept, or not. You can also teleport him/her to you (this happens only when `enable_immediate_teleport` is enabled on `config.lua`).   
Players can also teleport to coordinates, however, if the area is protected, the teleport will be denied.

## How to use:
Each command does a function. "**Example Usage**" is an example of how to use the command.   
Note there must be 2 players in order to make the commands to work: a player must send a request to another player (**see https://wiki.minetest.net/Server or see https://wiki.minetest.net/Setting_up_a_server for more information**).  
These are the following commands available in-game:

``` /tpr [playername] ```
- **Name:** Teleport Request
- **Description:** Requests permission to teleport to another player, where [playername] is their exact name.
- **Required Privileges:** `interact, tp`
- **Example Usage:** */tpr RobbieF* - requests permission from RobbieF to teleport to them.
- **Notes:** Usernames are case-sensitive. If you have "tp_admin" privilege, you will immediately teleport to the specificed player.

``` /tphr [playername] ```
- **Name:** Teleport Here Request
- **Description:** Request permission to teleport another player to you.
- **Required Privileges:** `interact, tp`
- **Example Usage:** /tphr RobbieF - requests RobbieF to teleport to you.
- **Notes:** Usernames are case-sensitive. If you have "tp_admin" privilege, RobbieF will teleport to you immediately.

``` /tpc [x,y,z] ```
- **Name:** Teleport to Coordinates
- **Description:** Teleport to coordinates.
- **Required Privileges:** `interact, tp_tpc, tp`
- **Notes:** Honors area protection: if the area is protected, it must be owned by you in order to teleport to it, or you must have "areas" privilege in order to teleport to those coordinates (this does not apply if "areas" mod is not detected).

``` /tpj [axis] [distance] ```
- **Name:** Teleport Jump
- **Description:** Teleport a specified distance along a single specified axis.
- **Required Privilege:** `interact", tp, tp_tpc`
- **Available Options for *axis*:** x, y, z
- **Example Usage:** '/tpj y 10' - teleport 10 nodes into the air.

``` /tpe ```
- **Name:** Teleport Evade
- **Description:** In a sticky situation? Evade your enemy by teleporting to several nearby coordinates in random pattern. There's no knowing where you'll end up.
- **Required Privileges:** `interact, tp_tpc, tp`
- **Example Usage:** '/tpe' - teleports you to a random number of random coordinates in an evasive pattern.

``` /tpy ```
- **Description:** Accept a user's request to teleport to you or teleport you to them.

``` /tpn ```
- **Description:** Deny a user's request to teleport to you or teleport you to them.

## Dependencies
There are no dependencies.  
However, optional dependencies are:
- [areas](https://github.com/minetest-mods/areas)
- [intllib](https://github.com/minetest-mods/intllib)

## Requirements
This mod requieres MT/MTG 5.0.0+ to run.   
Older versions not supported.

## Bugfixes & suggestions
Report bugs or suggest ideas by [creating an issue](https://github.com/ChaosWormz/teleport-request/issues/new).      
If you know how to fix an issue, or want something to be added, consider opening a [pull request](https://github.com/ChaosWormz/teleport-request/compare).

## License
[LGPL-2.1](https://github.com/ChaosWormz/teleport-request/blob/master/LICENSE.md) for everything.

## Contributors:
- [RobbieF](https://minetest.tv) | [GitHub](https://github.com/Cat5TV)
- [DonBatman](https://github.com/donbatman)
- [NathanS21](http://nathansalapat.com/) | [GitHub](https://github.com/NathanSalapat)
- [ChaosWormz](https://github.com/ChaosWormz)
- [Panquesito7](https://github.com/Panquesito7)
- [coil0](https://github.com/coil0)
- Traxie21, the original creator of this mod (however, he/she does not have a GitHub account anymore).

All those who contributed to the original mod (please see `init.lua`).

## Installation
- Unzip the archive, rename the folder to tpr and
place it in ..minetest/mods/

- GNU/Linux: If you use a system-wide installation place
    it in ~/.minetest/mods/.

- If you only want this to be used in a single world, place
    the folder in ..worldmods/ in your world directory.

For further information or help, see:
https://wiki.minetest.net/Installing_Mods

## TODO:
- Make it so if a player attempts to teleport to coordinates within a protected area owned by another player, and that player is online, the owner receives a request to allow or deny the user from teleporting to their area.
- Add limitations to /tpc which only allow a user to teleport X number of blocks. Prevents users from teleporting to the edge of the world.
- Assess value in changing all tpr-based chat commands to one global command such as /tp to reduce the chance of confusion between tps_admin and the original mod (and also make it so people don't have to remember so many commands).
- Create a better sound effect for teleport and apply it to all teleport methods (not just /tpc)
- Rewrite to place all chat commands into one single command much like how /teleport works.
- Make evade respect land: no teleporting inside land, but instead make sure player is standing on surface or in water.
