if exists('g:loaded_nvim_reLoad') | finish | endif


let s:save_cpo = &cpo  | set cpo&vim

com!  Reload  lua require('reLoad').Reload()
com!  Restart lua require('reLoad').Restart()

let g:loaded_nvim_reLoad = 1

let &cpo = s:save_cpo | unlet s:save_cpo

