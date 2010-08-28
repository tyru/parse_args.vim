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


function! s:grep_parse_args(args, default_flags) "{{{
    let GREP_WORD_PAT = '^/\(.\{-}[^\\]\)/\([gj]*\)'
    let args = a:args
    let list = []
    while args != ''
        let args = parse_args#skip_white(args)

        if args =~# GREP_WORD_PAT
            let [a, args] = parse_args#parse_pattern(args, GREP_WORD_PAT)
        else
            let [a, args] = parse_args#parse_one_arg_from_q_args(args)
        endif

        call add(list, a)
    endwhile
    return list
endfunction "}}}

function! parse_args#create_parser() "{{{
    let obj = {'rules': {}, '_parse_fn': {}}

    function! obj.get_handlers(args)
        " TODO
    endfunction

    function! obj.generate()
        for name in [
        \   'initialize_return_value',
        \   'each_loop_begin',
        \   'get_handlers',
        \   'each_loop_end',
        \]
            if has_key(self, name)
                let self._parse_fn[name] = self[name]
            endif
        endfor

        function! self.parse(args)
            let args = a:args
            let return_value = self._parse_fn.initialize_return_value()
            let sandbox = {}
            let fn_args_expr = '{"args": args, "return_value": return_value, "sandbox": sandbox}'

            while args != ''
                if has_key(self._parse_fn, 'each_loop_begin')
                    let args = self._parse_fn.each_loop_begin(eval(fn_args_expr))
                endif

                for [pattern, Fn; parent] in self._parse_fn.get_handlers(args)
                    if args =~# pattern
                        let call_args = [eval(fn_args_expr), pattern]
                        let match_fn_ret = empty(parent) ? call(Fn, call_args) : call(Fn, call_args, parent[0])
                        if has_key(match_fn_ret, 'args')
                            let args = match_fn_ret.args
                        endif
                        if get(match_fn_ret, 'do_break', 1)
                            break
                        endif
                    endif
                endfor

                if has_key(self._parse_fn, 'each_loop_end')
                    let args = self.each_loop_end(eval(fn_args_expr))
                endif
            endwhile
            return list
        endfunction
    endfunction

    return obj
endfunction "}}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
