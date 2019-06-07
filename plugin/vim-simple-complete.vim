if exists("g:loaded_vim_simple_complete")
  finish
endif
let g:loaded_vim_simple_complete = 1

let g:vsc_completion_command = get(g:, 'vsc_completion_command', "\<C-N>")
let g:vsc_reverse_completion_command = get(g:, 'vsc_reverse_completion_command', "\<C-P>")
let g:vsc_tab_complete = get(g:, 'vsc_tab_complete', 1)
let g:vsc_type_complete = get(g:, 'vsc_type_complete', 1)
let g:vsc_type_complete_length = get(g:, 'vsc_type_complete_length', 3)
let g:vsc_pattern = get(g:, 'vsc_pattern', '\k')
let g:vsc_complete_options = get(g:, 'vsc_complete_options', 'menu,menuone,noselect')
let g:vsc_pumheight = get(g:, 'vsc_pumheight', 10)

fun! s:TabCompletePlugin()
    inoremap <expr> <Tab> <SID>TabComplete(0)
    inoremap <expr> <S-Tab> <SID>TabComplete(1)

    fun! s:TabComplete(reverse)
        if s:CurrentChar() =~ g:vsc_pattern || pumvisible()
            return a:reverse ? g:vsc_reverse_completion_command : g:vsc_completion_command
        else
            return "\<Tab>"
        endif
    endfun
endfun

fun! s:CurrentChar()
    return matchstr(getline('.'), '.\%' . col('.') . 'c')
endfun

fun! s:TypeCompletePlugin()
    " Update completeopt settings.
    for cot_opt in split(g:vsc_complete_options, ',')
        " Don't override user set options.
        if &cot !~ cot_opt
            let &cot .= ',' . cot_opt
        endif
    endfor
    let &pumheight = g:vsc_pumheight
    let s:vsc_typed_length = 0
    imap <silent> <expr> <plug>(TypeCompleteCommand) <sid>TypeCompleteCommand()

    augroup TypeCompletePlugin
        autocmd!
        autocmd InsertCharPre * noautocmd call s:TypeComplete()
        autocmd InsertEnter * let s:vsc_typed_length = 0
    augroup END

    fun! s:TypeCompleteCommand()
        return g:vsc_completion_command
    endfun

    fun! s:TypeComplete()
        if v:char !~ g:vsc_pattern
            let s:vsc_typed_length = 0
            return
        endif

        let s:vsc_typed_length += 1

        if !g:vsc_type_complete || pumvisible()
            return
        endif

        if s:vsc_typed_length == g:vsc_type_complete_length
            call feedkeys("\<plug>(TypeCompleteCommand)", 'i')
        endif
    endfun
endfun

if g:vsc_type_complete | call s:TypeCompletePlugin() | endif
if g:vsc_tab_complete  | call s:TabCompletePlugin()  | endif
