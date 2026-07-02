return {
  "echasnovski/mini.ai",
  event = "VeryLazy",
  dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
  config = function()
    local ai = require("mini.ai")
    ai.setup({
      n_lines = 500,   -- how far to search for a text object
      custom_textobjects = {
        -- treesitter-based scopes. `ai.gen_spec.treesitter` pulls these
        -- from your installed parsers.
        f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
        c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
        a = ai.gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),
        o = ai.gen_spec.treesitter({   -- "block" — loops, conditionals, etc.
          a = { "@block.outer", "@conditional.outer", "@loop.outer" },
          i = { "@block.inner", "@conditional.inner", "@loop.inner" },
        }),
      },
    })
  end,
}
