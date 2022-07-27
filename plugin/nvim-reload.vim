if exists('g:loaded_nvim_reload') | finish | endif


let s:save_cpo = &cpo  | set cpo&vim

com!  Reload lua require('nvim-reload').Reload()
com!  Restart lua require('nvim-reload').Restart()

let g:loaded_nvim_reload = 1

let &cpo = s:save_cpo | unlet s:save_cpo

