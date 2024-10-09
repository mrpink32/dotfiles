{ config, lib, pkgs, inputs, ... }:
{
    imports = [
        inputs.nixvim.nixosModules.nixvim
    ];
    programs.nixvim = {
        enable = true;
        enableMan = true;
        package = pkgs.neovim-unwrapped;
        clipboard = {
            register = "unnamedplus";
            providers.wl-copy = {
                enable = true;
                package = pkgs.wl-clipboard;
            };
        };
        colorschemes.tokyonight = {
            enable = true;
            settings.style = "night";
        };
        globals.mapleader = " "; # Sets the leader key to space
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
            #clipboard = [ "unnamedplus" ];
        };
        keymaps = [
            {
                action = "<CMD>Neotree toggle<CR>";
                key = "<leader>t";
            }
            {
                action.__raw = "vim.lsp.buf.code_action";
                key = "<leader>ca";
                options.desc = "[C]ode [A]ction";
            }
            {
                action.__raw = "vim.lsp.buf.definition";
                key = "gd";
                options.desc = "[G]oto [D]efinition";
            }
            {
                action.__raw = "vim.lsp.buf.implementation";
                key = "gi";
                options.desc = "[G]oto [I]mplementations";
            }
            {
                action.__raw = "vim.lsp.buf.hover";
                key = "K";
                options.desc = "Hover Documentation";
            }
            {
                action.__raw = "vim.lsp.buf.signature_help";
                key = "<C-k>";
                options.desc = "Signature Documentation";
            }
            {
                action = "[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])";
                key = "<leader>s";
                mode = ["n"];
                options.desc = "Search and replace";
            }
        ];
        plugins = {
            web-devicons.enable = true;
            telescope = {
                enable = true;
                extensions.fzf-native = {
                    enable = true;
                    settings.fuzzy = true;
                };
                keymaps = {
                    "<leader>/" = {
                        action = "current_buffer_fuzzy_find";
                        options = {
                            desc = "[/] Fuzzily search in current buffer";
                        };
                    };
                    "<leader>?" = {
                        action = "oldfiles";
                        options = {
                            desc = "[?] Find recently opened files";
                        };
                    };
                    "<leader><space>" = {
                        action = "buffers";
                        options = {
                            desc = "[ ] Find existing buffers";
                        };
                    };
                    "<leader>gf" = {
                        action = "git_files";
                        options = {
                            desc = "[G]it [F]iles";
                        };
                    };
                    "<leader>gs" = {
                        action = "git_status";
                        options = {
                            desc = "[G]it [S]tatus";
                        };
                    };
                    "<leader>gc" = {
                        action = "git_commits";
                        options = {
                            desc = "[G]it [C]ommits";
                        };
                    };
                    "<leader>ff" = {
                        action = "find_files";
                        options = {
                            desc = "[F]ind [F]iles";
                        };
                    };
                    "<leader>gr" = {
                        action = "lsp_refrences";
                        options.desc = "[G]oto [R]efrence";
                    };
                    "<leader>fh" = {
                        action = "help_tags";
                        options = {
                            desc = "[F]ind [H]elp_tags";
                        };
                    };
                    "<leader>sd" = {
                        action = "diagnostics";
                        options = {
                            desc = "[S]earch [D]iagnostics";
                        };
                    };
                    "<leader>fb" = {
                        action = "buffers";
                        options = {
                            desc = "[F]ind existing [B]uffers";
                        };
                    };
                    "<leader>fg" = {
                        action = "live_grep";
                        options = {
                            desc = "[F]ind by [G]rep";
                        };
                    };
                };
            };
            treesitter = {
                enable = true;
                settings.indent.enable = true;
            };
            todo-comments.enable = true;
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
                inlayHints = true;
                servers = {
                    clangd = {
                        enable = true;
                        package = pkgs.llvmPackages_19.clang-tools;
                        #extraOptions = "-fexperimental-new-constant-interpreter";
                    };
                    rust_analyzer = {
                        enable = true;
                        package = pkgs.rust-analyzer-unwrapped;
                        installCargo = false;
                        installRustc = false;
                    };
                    zls = {
                        enable = true;
                        package = inputs.zls.packages.${pkgs.system}.zls;
                    };
                    nixd.enable = true;
                    omnisharp = {
                        enable = true;
                        package = pkgs.omnisharp-roslyn;
                    };
                    csharp_ls = {
                        enable = false;
                        package = pkgs.csharp-ls;
                    };
                    html = {
                        enable = true;
                    };
                    cssls = {
                        enable = true;
                    };
                    ts_ls = {
                        enable = true;
                        #package = pkgs.nodePackages_latest.typescript-language-server;
                    };
                    ols = {
                        enable = true;
                        package = pkgs.ols;
                        autostart = true;
                    };
                };
            };
            lint = {
                enable = true;
            };
            zig = {
                enable = true;
                package = (inputs.zig.packages.${"x86_64-linux"}.master);
            };
        };
    };
}
