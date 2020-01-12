unused_args = false
allow_defined_top = true
max_line_length = 999

globals = {
	"tp"
}

read_globals = {
	-- Stdlib
	string = {fields = {"split", "trim"}},
	table = {fields = {"copy", "getn"}},

	-- Minetest
	"minetest",
	"vector", "ItemStack",
	"dump", "dump2", "chat2",

    "gamehub",
    "intllib", "pos2",
    "target_coords", "chatmsg",
    "name2", "target", "source", "areas",

	-- Deps

}