{ config, lib, pkgs, inputs, ... }:

{
    imports = [
        inputs.nixvim.nixosModules.nixvim
    ];

    programs.nixvim = {
        enable = true;
        enableMan = true;
        package = pkgs.neovim-unwrapped;
        colorschemes.tokyonight = {
            enable = true;
            settings.style = "night";
        };

        globals.mapleader = ","; # Sets the leader key to comma

        opts = {
            number = true;
            relativenumber = true;

            expandtab = true;
            tabstop = 4;
            softtabstop = 4;
            shiftwidth = 4;

            autoindent = true;
            smartindent = true;

            encoding = "UTF-8";

            wrap = false;

            backup = false;

            hlsearch = false;
            incsearch = true;

            termguicolors = true;

            scrolloff = 12;
            sidescrolloff = 12;
            signcolumn = "yes";

            updatetime = 120;

            colorcolumn = "80";

            winbl = 30;

            mouse = "";
            mousehide = true;
            mousescroll = "ver:0,hor:0";

            cursorline = true;
            cursorcolumn = true;
            cursorlineopt = "both";

            timeout = true;
            timeoutlen = 300;
        };

        keymaps = [
            {
                action = "<CMD>Neotree toggle<CR>";
                key = "<leader>t";
            }
            {
                action = "vim.lsp.buf.code_action";
                key = "<leader>ca";
                lua = true;
                options.desc = "[C]ode [A]ction";
            }
            {
                action = "vim.lsp.buf.definition";
                key = "gD";
                lua = true;
                options.desc = "[G]oto [D]efinition";
            }
            #{
            #    action = "require('telescope.builtin').lsp_refrences";
            #    key = "gR";
            #    lua = true;
            #    options.desc = "[G]oto [R]efrence";
            #}
            {
                action = "vim.lsp.buf.implementation";
                key = "gI";
                lua = true;
                options.desc = "[G]oto [I]mplementations";
            }
            {
                action = "vim.lsp.buf.hover";
                key = "K";
                lua = true;
                options.desc = "Hover Documentation";
            }
            {
                action = "vim.lsp.buf.signature_help";
                key = "<C-k>";
                lua = true;
                options.desc = "Signature Documentation";
            }
        ];

        plugins = {
            nix-develop.enable = true;
            telescope.enable = true;
            treesitter = {
                enable = true;
                indent = true;
            };
            lualine.enable = true;
            luasnip.enable = true;
            neo-tree = {
                enable = true;
                eventHandlers = {
                    file_opened = "
                        function(file_path)
                        --auto close
                        require('neo-tree.command').execute({action = 'close'})
                        end
                        ";
                };
            };
            which-key.enable = true;
            indent-blankline.enable = true;
            cmp-nvim-lsp.enable = true;
            cmp_luasnip.enable = true;
            cmp-vsnip.enable = true;
            cmp = {
                enable = true;
                autoEnableSources = true;
                settings = {
                    snippet = {
                        expand = "function(args) require('luasnip').lsp_expand(args.body) end";
                    };
                    mapping = {
                        "<C-n>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
                        "<C-p>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
                        "<C-d>" = "cmp.mapping.scroll_docs(-4)";
                        "<C-f>" = "cmp.mapping.scroll_docs(4)";
                        "<C-Space>" = "cmp.mapping.complete()";
                        "<CR>" = "cmp.mapping.confirm({ select = true })";
                        "<C-e>" = "cmp.mapping.close()";
                    };
                    sources = [
                        { name = "nvim_lsp"; }
                        #{ name = "luasnip"; }
                        { name = "vsnip"; }
                        #{ name = "path"; }
                        #{ name = "buffer"; }
                    ];
                };
            };
            lsp = {
                enable = true;
                servers = {
                    clangd = {
                        enable = true;
                        package = pkgs.clang-tools_18;
                    };
                    rust-analyzer = {
                        enable = true;
                        package = pkgs.rust-analyzer-unwrapped;
                        installCargo = false;
                        installRustc = false;
                    };
                    zls = {
                        enable = true;
                        package = inputs.nixpkgs-zls.packages.${pkgs.system}.zls;
                    };
                    nixd.enable = true;
                    #csharp-ls.enable = true;
                    omnisharp.enable = true;
                    tsserver = {
                        enable = true;
                        package = pkgs.nodePackages_latest.typescript-language-server;
                    };
                };
            };
        };
    };
}

