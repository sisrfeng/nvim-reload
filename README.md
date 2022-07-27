If you meet this issue https://github.com/famiu/nvim-reload/issues/8,
just remove these under vim-polyglot
![image](https://user-images.githubusercontent.com/53520949/160841723-d0cf07f7-95fc-46b3-b855-9526910ef686.png)


# Origin author's readme
---
# nvim-reload
## About
Nvim-reload is a Neovim plugin that allows you to reload your entire Neovim config completely,
including your start plugins.
It also reloads all lua modules inside your Neovim config directory.

this project is no longer being maintained.
you might still be able to use it but do not expect any issues you have with it to be fixed.
    those willing to maintain it can feel free to create a fork

### Requires:
* [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)

```
Plug 'famiu/nvim-reload'
```

## How to use
Just install the plugin and it'll define two commands for you,
`:Reload` and `:Restart`,
to reload and restart your Vim config, respectively.
Note that 'restart' here just means reloading and
manually triggering the `VimEnter` autocmd to emulate a new run of Vim, it will not actually restart Vim.

You can also use the following Lua functions `require('nvim-reload').Reload()` and `require('nvim-reload').Restart()` 
instead of the `:Reload` and `:Restart` commands.

### Configuration
By default, nvim-reload reloads:
* Your init file.
* Your config files (VimL files in `stdpath('config')`. 
* Your start plugins
    (plugins that are automatically loaded when Neovim is started,
    located in `stdpath('data')/site/pack/*/start/*`).

    **NOTE:** The asterisks used above are file globs, not literal asterisks.

In case you didn't know,
    Lua caches the modules you load using `require()`.
    Which can prevent you from reloading your configuration since
        Lua will use the cached version of your config instead of the modified version.
    So the plugin also unloads the Lua modules inside your Neovim config located in `stdpath('config')/lua`,
        which makes Lua actually reload them.

If you want, you can change the default behavior through the following configuration options.

* `vim_reload_dirs` - Table containing list of directories to reload the Vim files from. The plugin will look into the `'compiler'`, `'doc'`, `'keymap'`, `'syntax'` and `'plugin'` subdirectories of each directory provided here and reload all VimL files in them.<br>Default: `{ vim.fn.stdpath('config'), vim.fn.stdpath('data') .. '/site/pack/*/start/*' }`

* `lua_reload_dirs` - Table containing list of directories to load the Lua modules from. The plugin will look into the `lua` subdirectory of each directory provided here for modules to reload.<br>Default: `{ vim.fn.stdpath('config') }`

* `files_reload_external` - Table containing paths to external VimL files (files not inside any of the `vim_reload_dirs`) to reload.<br>Default: `{}`

* `modules_reload_external` - Table containing Names of external modules (modules not inside any of the `lua_reload_dirs`) to reload.<br>Default: `{}`

* `pre_reload_hook` - Function to run before reloading the config.
<br>Default: `nil`

* `post_reload_hook` - Function to run after reloading the config.
<br>Default: `nil`

#### Example config:
```lua
local reload = require('nvim-reload')

-- If you use Neovim's built-in plugin system
-- Or a plugin manager that uses it (eg: packer.nvim)
local plugin_dirs = vim.fn.stdpath('data') .. '/site/pack/*/start/*'

-- If you use vim-plug
-- local plugin_dirs = vim.fn.stdpath('data') .. '/plugged/*'

reload.vim_reload_dirs = {
    vim.fn.stdpath('config'),
    plugin_dirs
}

reload.lua_reload_dirs = {
    vim.fn.stdpath('config'),
    -- Note: the line below may cause issues reloading your config
    plugin_dirs
}

reload.files_reload_external = {
    vim.fn.stdpath('config') .. '/myfile.vim'
}

reload.modules_reload_external = { 'packer' }

reload.post_reload_hook = function()
    require('feline').reset_highlights()
end
```

**NOTE:** The directories provided in `lua_reload_dirs` and `vim_reload_dirs` can be globs, which will automatically be expanded by the plugin.

## Note
This plugin is still quite new and might have some bugs. And in case it does, feel free to make an issue here to report them.

## Self-plug
If you liked this plugin, also check out:
- [feline.nvim](https://github.com/famiu/feline.nvim) - A nice customizable statusline for Neovim written in Lua.
- [bufdelete.nvim](https://github.com/famiu/bufdelete.nvim) - Delete Neovim buffers without losing your window layout.
