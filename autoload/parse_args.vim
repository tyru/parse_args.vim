" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Load Once {{{
if exists('g:loaded_parse_args') && g:loaded_parse_args
    finish
endif
let g:loaded_parse_args = 1
" }}}
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}



function! parse_args#skip_white(q_args) "{{{
    return substitute(a:q_args, '^\s*', '', '')
endfunction "}}}


function! parse_args#parse_pattern(str, pat) "{{{
    let str = a:str
    " TODO: Use matchlist() for capturing group \1, \2, ...
    " and specify which group to use with arguments.
    let head = matchstr(str, a:pat)
    let rest = strpart(str, strlen(head))
    return [head, rest]
endfunction "}}}


function! parse_args#parse_one_arg_from_q_args(q_args) "{{{
    let q_args = parse_args#skip_white(a:q_args)
    return parse_args#parse_pattern(q_args, '^.\{-}[^\\]\ze\([ \t]\|$\)')
endfunction "}}}
function! parse_args#eat_n_args_from_q_args(q_args, n) "{{{
    let rest = a:q_args
    for _ in range(1, a:n)
        let rest = parse_args#parse_one_arg_from_q_args(rest)[1]
    endfor
    let rest = parse_args#skip_white(rest)    " for next arguments.
    return rest
endfunction "}}}


function! parse_args#parse_one_string_from_q_args(q_args) "{{{
    " TODO
endfunction "}}}



" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
