return {
	"echasnovski/mini.pairs",
	event = "InsertEnter",
	-- Default setup auto-closes ( [ { " ' ` and also:
	--   - deletes both characters when you press <BS> inside an empty pair
	--   - skips over the closing character instead of inserting a duplicate
	opts = {},
}
