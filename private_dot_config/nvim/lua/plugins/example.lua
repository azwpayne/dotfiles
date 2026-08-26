-- since this is just an example spec, don't actually load anything here and return an empty spec
-- stylua: ignore
-- if true then return {} end

-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
--
-- For more information see: https://lazyvim.github.io/guide/return-a-plugin-return-func/
return {
    -- ============================================================================
    -- Example: Add Gruvbox colorscheme
    -- ============================================================================
    -- Add gruvbox colorscheme uncommenting the line below:
    -- { "ellisonleao/gruvbox.nvim" },

    -- Configure LazyVim to load gruvbox with catppuccin as default
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "catppuccin",
        },
    },

    -- ============================================================================
    -- Example: Configure Trouble (diagnostic window)
    -- ============================================================================
    -- Configure LazyVim to use diagnostic signs with Trouble
    {
        "folke/trouble.nvim",
        opts = { use_diagnostic_signs = true },
    },

    -- Disable Trouble if you don't need it
    -- { "folke/trouble.nvim", enabled = false },

    -- ============================================================================
    -- Example: Add nvim-cmp with emoji source
    -- ============================================================================
    -- Disabled (was inert dead config): LazyVim v14 ships blink.cmp as its
    -- completion engine and drops nvim-cmp specs unless the
    -- "lazyvim.plugins.extras.coding.nvim-cmp" extra is imported, so this spec
    -- never actually loaded (cmp-emoji is consequently absent from
    -- lazy-lock.json). To enable, import that extra first and run :Lazy sync
    -- so cmp-emoji gets pinned, then uncomment:
    -- {
    --     "hrsh7th/nvim-cmp",
    --     dependencies = { "hrsh7th/cmp-emoji" },
    --     ---@param opts cmp.ConfigSchema
    --     opts = function(_, opts)
    --         table.insert(opts.sources, { name = "emoji" })
    --     end,
    -- },

    -- ============================================================================
    -- Example: Telescope plugin file browser
    -- ============================================================================
    -- Add a keymap to browse plugin files
    {
        "nvim-telescope/telescope.nvim",
        keys = {
            -- Find plugin file with leader+fp
            -- stylua: ignore
            {
                "<leader>fp",
                function() require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root }) end,
                desc = "Find Plugin File",
            },
        },
        -- Change some telescope options
        opts = {
            defaults = {
                layout_strategy = "horizontal",
                layout_config = { prompt_position = "top" },
                sorting_strategy = "ascending",
                winblend = 0,
            },
        },
    },

    -- ============================================================================
    -- Example: Add pyright for Python LSP
    -- ============================================================================
    -- Add pyright to lspconfig (automatically installed with mason)
    {
        "neovim/nvim-lspconfig",
        ---@class PluginLspOpts
        opts = {
            ---@type lspconfig.options
            servers = {
                -- pyright will be automatically installed with mason and loaded with lspconfig
                pyright = {},
            },
        },
    },

    -- ============================================================================
    -- Example: Add tsserver with typescript.nvim
    -- ============================================================================
    -- Add tsserver and setup with typescript.nvim instead of lspconfig
    -- {
    --     "neovim/nvim-lspconfig",
    --     dependencies = {
    --         "jose-elias-alvarez/typescript.nvim",
    --         init = function()
    --             require("lazyvim.util").lsp.on_attach(function(_, buffer)
    --                 -- Organize imports
    --                 -- stylua: ignore
    --                 vim.keymap.set("n", "<leader>co", "TypescriptOrganizeImports",
    --                     { buffer = buffer, desc = "Organize Imports" })
    --                 -- Rename file
    --                 vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { desc = "Rename File", buffer = buffer })
    --             end)
    --         end,
    --     },
    --     ---@class PluginLspOpts
    --     opts = {
    --         ---@type lspconfig.options
    --         servers = {
    --             -- tsserver will be automatically installed with mason and loaded with lspconfig
    --             tsserver = {},
    --         },
    --         -- You can do any additional lsp server setup here
    --         -- Return true if you don't want this server to be setup with lspconfig
    --         ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
    --         setup = {
    --             -- Example to setup with typescript.nvim
    --             tsserver = function(_, opts)
    --                 require("typescript").setup({ server = opts })
    --                 return true
    --             end,
    --             -- Specify * to use this function as a fallback for any server
    --             -- ["*"] = function(server, opts) end,
    --         },
    --     },
    -- },

    -- Or use the LazyVim extra for typescript
    -- { import = "lazyvim.plugins.extras.lang.typescript" },

    -- ============================================================================
    -- Add more treesitter parsers
    -- ============================================================================
    -- Ensure these parsers are installed for syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "bash",
                "html",
                "javascript",
                "json",
                "lua",
                "markdown",
                "markdown_inline",
                "python",
                "query",
                "regex",
                "tsx",
                "typescript",
                "vim",
                "yaml",
            },
        },
    },

    -- Extend default treesitter config with additional parsers
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            -- Add tsx and typescript to ensure_installed
            vim.list_extend(opts.ensure_installed, {
                "tsx",
                "typescript",
            })
        end,
    },

    -- ============================================================================
    -- Configure lualine with custom sections
    -- ============================================================================
    -- Add a custom component to lualine_x (right side)
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        opts = function(_, opts)
            table.insert(opts.sections.lualine_x, {
                function()
                    return "😄"
                end,
            })
        end,
    },

    -- Or specify new options to override all the defaults
    -- Disabled: in lazy.nvim an opts function's return value replaces the
    -- merged opts, so returning {} here wipes LazyVim's entire lualine config
    -- (and the emoji component added above). Uncomment only together with a
    -- real config:
    -- {
    --     "nvim-lualine/lualine.nvim",
    --     event = "VeryLazy",
    --     opts = function()
    --         return {
    --             --[[add your custom lualine config here]]
    --         }
    --     end,
    -- },

    -- ============================================================================
    -- Use mini.starter instead of alpha
    -- ============================================================================
    -- Start screen alternative
    -- { import = "lazyvim.plugins.extras.ui.mini-starter" },

    -- ============================================================================
    -- Add jsonls and schemastore packages
    -- ============================================================================
    -- Setup treesitter for json, json5 and jsonc
    -- { import = "lazyvim.plugins.extras.lang.json" },

    -- ============================================================================
    -- Add tools you want to have installed
    -- ============================================================================
    -- Mason setup for LSP/dap/tools installers
    {
        "mason-org/mason.nvim",
        opts = {
            ensure_installed = {
                "stylua",           -- Lua formatter
                "shellcheck",       -- Shell script checker
                "shfmt",            -- Shell script formatter
                "flake8",           -- Python linter
                -- "prettier",       -- JS formatter (enable if needed)
            },
        },
    },

    -- ============================================================================
    -- Example: Debug adapter setup
    -- ============================================================================
    -- { import = "lazyvim.plugins.extras.dap.python" },

    -- ============================================================================
    -- Example: Add git commands navigation
    -- ============================================================================
    -- { import = "lazyvim.plugins.extras.ui.gitsigns" },
}