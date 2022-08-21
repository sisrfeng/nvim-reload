-- 准备工作
    local M = {}

    local fn  = vim.fn
    local cmd = vim.cmd

    local scan_dir = require('plenary.scandir').scan_dir    

    local Path = require('plenary.path')
    local function path_exists(path)
        return Path:new(path):exists()
    end

    -- vimL
        local viml_subdirs = {
            'compiler' ,
            'doc'      ,
            'keymap'   ,
            'syntax'   ,
            'plugin'
        }

        local function files_in_path(runtimepath)
            -- Ignore opt plugins
            if string.match(runtimepath, "/site/pack/.-/opt") then
                return {}
            end

            local runtime_files = {}

            -- Search each subdirectory  listed in viml_subdirs of runtimepath for files
            for _, subdir in ipairs(viml_subdirs) do
                local viml_path = string.format("%s/%s", runtimepath, subdir)

                if path_exists(viml_path) then
                    local files = scan_dir(viml_path, { search_pattern = '%.n?vim$', hidden = true })

                    for _, file in ipairs(files) do
                        runtime_files[#runtime_files+1] = file
                    end
                end
            end

            return runtime_files
        end


        M.vim_reload_dirs = {fn.stdpath('config'),
                             fn.stdpath('data') .. '/site/pack/*/start/*',
                            }
        M.files_reload_external = {}  -- files outside the runtimepaths to source

        -- Search each runtime path for files
        local function reload_vimL()
        -- 现在没调用这函数, 只处理lua
            for _, a_runtime in ipairs(M.vim_reload_dirs)  do
                -- Expand the globs and get the result as a list
                local paths = fn.glob(a_runtime, 0, 1)

                for _, path in ipairs(paths) do
                    local runtime_files = files_in_path(path)

                    for _, file in ipairs(runtime_files) do
                        cmd('source ' .. file)
                    end
                end
            end

            for _, file in ipairs(M.files_reload_external) do
                cmd('source ' .. file)
            end
        end


    -- lua
        local function escape_str(str)
            local patterns_to_escape = {
                '%^' ,
                '%$' ,
                '%(' ,
                '%)' ,
                '%%' ,
                '%.' ,
                '%[' ,
                '%]' ,
                '%*' ,
                '%+' ,
                '%-' ,
                '%?' 
            }

            return string.gsub(
                str                                                     ,
                string.format("([%s])", table.concat(patterns_to_escape)) ,
                '%%%1'
            )
        end


        local function get_lua_modules_in_path(runtimepath)
            local luapath = string.format("%s/lua", runtimepath)

            if not path_exists(luapath) then
                return {}
            end

            -- Search lua directory of runtimepath for modules
            local modules = scan_dir(luapath, { search_pattern = '%.lua$', hidden = true })

            for i, module in ipairs(modules) do
                -- Remove runtimepath and file extension from module path
                module = string.match(
                    module,
                    string.format(
                        '%s/(.*)%%.lua',
                        escape_str(luapath)
                    )
                )

                -- Changes slash in path to dot to follow lua module format
                module = string.gsub(module, "/", ".")

                -- If module ends with '.init', remove it.
                module = string.gsub(module, "%.init$", "")

                -- Override previous value with new value
                modules[i] = module
            end

            return modules
        end
        

        local function unload_lua_modules()
            -- Search each runtime path for modules
            for _, a_runtime in ipairs( { fn.stdpath('config') } ) do
                local paths = fn.glob(a_runtime, 0, 1)

                for _, path in ipairs(paths) do
                    local modules = get_lua_modules_in_path(path)

                    for _, module in ipairs(modules) do
                        package.loaded[module] = nil
                    end
                end
            end

            -- Lua modules outside the runtimepaths to unload
                -- for _, module in ipairs( {某路径} ) do
                    -- package.loaded[module] = nil
                -- end
        end

-- 主角 / main
    -- M.pre_reload_hook  = nil
    -- M.post_reload_hook = nil
    
    function M.ReLua()
        -- M.pre_reload_hook()

        -- Stop LSP if it's configured
        if fn.exists(':LspStop') ~= 0 then
            cmd('LspStop')
        end

        unload_lua_modules()

        -- if string.match(fn.expand('$MYVIMRC'), '%.lua$') then
        --     cmd('luafile $MYVIMRC')
        -- else
        --     cmd('source $MYVIMRC')
        -- end
        
        -- reload_vimL()    有些vimscript在启动vim时不需要load, 这行会导致报错

        -- M.post_reload_hook()
    end

    function M.ReStart()
        M.ReLua() 
        cmd('doautocmd VimEnter')
    end
-- 本lua文件最终的返回
return M



-- 之前放在/home/wf/dotF/cfg/nvim/lua/my_cfg.lua的关于reload的配置
        -- local load2 = require('nvim-reload')
        --     -- load2.pre_reload_hook = function()
        --     --     print('准备reload!')
        --     -- end
        --
        --     local plugin_dirs = vim.fn.stdpath('data') .. '/plugged/*'  -- If you use vim-plug
        --             -- -- If you use Neovim's built-in plugin system
        --             -- -- Or a plugin manager that uses it (eg: packer.nvim)
        --             -- local plugin_dirs = vim.fn.stdpath('data') .. '/site/pack/*/start/*'
        --
        --      --   reload all VimL files in them
        --         load2.vim_reload_dirs = {
        --             -- vim.fn.stdpath('config'),
        --                                     --先不加这行只reload我的init.vim就好,
        --             plugin_dirs
        --         }
        --                   -- vim_reload_dirs:
        --                   --    Table(字典)
        --                   --    containing  list of directories to reload the Vim files from.
        --                   --    This plugin will look into the subdirectories of each directory provided here
        --                   --         compiler
        --                   --         doc
        --                   --         keymap
        --                   --         syntax
        --                   --         plugin
        --
        --         -- `files_reload_external`:  上述的补充
        --         load2.files_reload_external = {
        --             vim.fn.stdpath('config') .. '/init.vim'
        --         }
        --
        --
        --      --  reload all lua files in them
        --         load2.lua_reload_dirs = {
        --             vim.fn.stdpath('config')
        --             -- 会进入lua目录吧
        --             -- Note: the line below may cause issues reloading your config:
        --             -- plugin_dirs
        --         }
        --
        --         -- 上述的补充
        --         load2.modules_reload_external = {}
        --         -- reload.modules_reload_external = { 'packer' }
        --
        --
        --     -- -- Function to run after reloading the config.
        --     -- load2.post_reload_hook = function()
        --     --     print('reloaded! leo__________________________')
        --     --     -- require('feline').reset_highlights()
        --     -- end
    --要退出vim重启才生效, reload不行, 还是自己用vimL写吧
    -- -- nvim-reload的配置结束-<--<--<--<--<-<-<

