if exists('g:loaded_nvim_reLoad') | finish | endif


let s:save_cpo = &cpo  | set cpo&vim

com!  ReLua   lua require('reLoad').ReLua()
com!  ReStart lua require('reLoad').ReStart()

let g:loaded_nvim_reLoad = 1

let &cpo = s:save_cpo | unlet s:save_cpo

