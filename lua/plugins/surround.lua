return {
	"echasnovski/mini.surround",
	event = "VeryLazy",
	opts = {
		custom_surroundings = {
			-- press this trigger key after `sa`, and it wraps with '''
			["T"] = { -- "T" for triple-quote (pick any free letter)
				output = { left = "'''", right = "'''" },
			},
		},
	},
}
