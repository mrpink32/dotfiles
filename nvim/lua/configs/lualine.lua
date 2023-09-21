require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = '|', -- { left = '', right = ''},
    section_separators = '', -- { left = '', right = '' }, -- { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
      lualine_a = {'mode'},
      lualine_b = {
          'branch',
          'diff',
          {
              'diagnostics',
              source = {'nvim'},
              sections = {'error'},
              diagnostics_color = {error={bg='#ca1243',fg='#f3f3f3'}},
          },
          {
              'diagnostics',
              source = {'nvim'},
              sections = {'warn'},
              diagnostics_color = {error={bg='#fe8019',fg='#f3f3f3'}},
          },
          -- 'diagnostics'
      },
      lualine_c = {'buffers'},
      lualine_x = {'encoding', 'fileformat', 'filetype'},
      lualine_y = {'progress'},
      lualine_z = {'location'},
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {},
}
