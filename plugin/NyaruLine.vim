" 存在するなら読み込み済みなのでfinish
if exists('g:loaded_NyaruLine')
    finish
endif
let g:loaded_NyaruLine = 1



"--------------------------------------------------------------------------------
" Setting Color Functions
"--------------------------------------------------------------------------------

" returns an approximate grey index for the given grey level
function! <SID>grey_number(x)
    if &t_Co == 88
        if a:x < 23
            return 0
        elseif a:x < 69
            return 1
        elseif a:x < 103
            return 2
        elseif a:x < 127
            return 3
        elseif a:x < 150
            return 4
        elseif a:x < 173
            return 5
        elseif a:x < 196
            return 6
        elseif a:x < 219
            return 7
        elseif a:x < 243
            return 8
        else
            return 9
        endif
    else
        if a:x < 14
            return 0
        else
            let l:n = (a:x - 8) / 10
            let l:m = (a:x - 8) % 10
            if l:m < 5
                return l:n
            else
                return l:n + 1
            endif
        endif
    endif
endfun


" returns the actual grey level represented by the grey index
function! <SID>grey_level(n)
    if &t_Co == 88
        if a:n == 0
            return 0
        elseif a:n == 1
            return 46
        elseif a:n == 2
            return 92
        elseif a:n == 3
            return 115
        elseif a:n == 4
            return 139
        elseif a:n == 5
            return 162
        elseif a:n == 6
            return 185
        elseif a:n == 7
            return 208
        elseif a:n == 8
            return 231
        else
            return 255
        endif
    else
        if a:n == 0
            return 0
        else
            return 8 + (a:n * 10)
        endif
    endif
endfun


" returns the palette index for the given grey index
function! <SID>grey_color(n)
    if &t_Co == 88
        if a:n == 0
            return 16
        elseif a:n == 9
            return 79
        else
            return 79 + a:n
        endif
    else
        if a:n == 0
            return 16
        elseif a:n == 25
            return 231
        else
            return 231 + a:n
        endif
    endif
endfun


" returns an approximate color index for the given color level
function! <SID>rgb_number(x)
    if &t_Co == 88
        if a:x < 69
            return 0
        elseif a:x < 172
            return 1
        elseif a:x < 230
            return 2
        else
            return 3
        endif
    else
        if a:x < 75
            return 0
        else
            let l:n = (a:x - 55) / 40
            let l:m = (a:x - 55) % 40
            if l:m < 20
                return l:n
            else
                return l:n + 1
            endif
        endif
    endif
endfun


" returns the actual color level for the given color index
function! <SID>rgb_level(n)
    if &t_Co == 88
        if a:n == 0
            return 0
        elseif a:n == 1
            return 139
        elseif a:n == 2
            return 205
        else
            return 255
        endif
    else
        if a:n == 0
            return 0
        else
            return 55 + (a:n * 40)
        endif
    endif
endfun


" returns the palette index for the given R/G/B color indices
function! <SID>rgb_color(x, y, z)
    if &t_Co == 88
        return 16 + (a:x * 16) + (a:y * 4) + a:z
    else
        return 16 + (a:x * 36) + (a:y * 6) + a:z
    endif
endfun


" returns the palette index to approximate the given R/G/B color levels
function! <SID>color(r, g, b)
    " get the closest grey
    let l:gx = <SID>grey_number(a:r)
    let l:gy = <SID>grey_number(a:g)
    let l:gz = <SID>grey_number(a:b)

    " get the closest color
    let l:x = <SID>rgb_number(a:r)
    let l:y = <SID>rgb_number(a:g)
    let l:z = <SID>rgb_number(a:b)

    if l:gx == l:gy && l:gy == l:gz
        " there are two possibilities
        let l:dgr = <SID>grey_level(l:gx) - a:r
        let l:dgg = <SID>grey_level(l:gy) - a:g
        let l:dgb = <SID>grey_level(l:gz) - a:b
        let l:dgrey = (l:dgr * l:dgr) + (l:dgg * l:dgg) + (l:dgb * l:dgb)
        let l:dr = <SID>rgb_level(l:gx) - a:r
        let l:dg = <SID>rgb_level(l:gy) - a:g
        let l:db = <SID>rgb_level(l:gz) - a:b
        let l:drgb = (l:dr * l:dr) + (l:dg * l:dg) + (l:db * l:db)
        if l:dgrey < l:drgb
            " use the grey
            return <SID>grey_color(l:gx)
        else
            " use the color
            return <SID>rgb_color(l:x, l:y, l:z)
        endif
    else
        " only one possibility
        return <SID>rgb_color(l:x, l:y, l:z)
    endif
endfun


" returns the palette index to approximate the 'rrggbb' hex string
function! <SID>rgb(rgb)
    let l:r = ("0x" . strpart(a:rgb, 0, 2)) + 0
    let l:g = ("0x" . strpart(a:rgb, 2, 2)) + 0
    let l:b = ("0x" . strpart(a:rgb, 4, 2)) + 0

    return <SID>color(l:r, l:g, l:b)
endfun


" sets the highlighting for the given group
function! <SID>X(group, fg, bg, attr)
    " if a:fg != ''
    " return 'hi ' . a:group . ' guifg=#' . a:fg . ' ctermfg=' . <SID>rgb(a:fg)
    " endif
    " if a:bg != ''
    " return 'hi ' . a:group . ' guibg=#' . a:bg . ' ctermbg=' . <SID>rgb(a:bg)
    " endif
    " if a:attr != ''
    " return 'hi ' . a:group . ' gui=' . a:attr . ' cterm=' . a:attr
    " endif

    if a:fg != '' && a:bg != '' && a:attr != ''
        return 'hi ' . a:group . ' gui=' . a:attr . ' cterm=' . a:attr . ' guifg=#' . a:fg . ' ctermfg=' . <SID>rgb(a:fg) . ' guibg=#' . a:bg . ' ctermbg=' . <SID>rgb(a:bg)
    elseif
        echoerr 'Highlight param is missing'
    endif
endfunction


function! <SID>X2(fg, bg, attr)
    if a:fg != '' && a:bg != '' && a:attr != ''
        return 'gui=' . a:attr . ' cterm=' . a:attr . ' guifg=#' . a:fg . ' ctermfg=' . <SID>rgb(a:fg) . ' guibg=#' . a:bg . ' ctermbg=' . <SID>rgb(a:bg)
    elseif
        echoerr 'Highlight param is missing'
    endif
endfunction



"--------------------------------------------------------------------------------
" Variables
"--------------------------------------------------------------------------------

" statuslineのデータ, それを操作する関数の2つを持つ
" type - mode - atom 構造
" typeのmode名defaultを標準
let g:nyaruline_expr_controler = {}

" 自身に指定した名前のtypeを追加
function! g:nyaruline_expr_controler.add_type(name) "
    let self[a:name] = deepcopy(s:template_type_dict)

    " 参照を返す
    return self[a:name]
endfunction

function! g:nyaruline_expr_controler.get_highlight_param(fg, bg, attr)
    return <SID>X2(a:fg, a:bg, a:attr)
endfunction

" typeのテンプレート
" modeを持つ
let s:template_type_dict = {}

" 自身に指定した名前のmodeを追加
function! s:template_type_dict.add_mode(name) "
    let self[a:name] = deepcopy(s:template_mode_dict)

    " 参照を返す
    return self[a:name]
endfunction

" モードを複製
function! s:template_type_dict.copy_mode(from, dist)
    let self[a:dist] = deepcopy(self[a:from])

    let self[a:dist].is_load = 0

    return self[a:dist]
endfunction


" modeのテンプレート
" 読み込み確認やatomのリストを持つ
let s:template_mode_dict = {
            \ 'is_load' : 0,
            \ 'statusline_expr' : '',
            \ 'atom_list' : [],
            \ }

" 自身に指定した設定のatomを追加
function! s:template_mode_dict.add_atom(index, expr, hi_name, hi_expr, side) "
    let atom = {}
    let atom.is_load = 0
    let atom.expr = a:expr
    let atom.highlight_name = a:hi_name
    let atom.highlight_expr = a:hi_expr
    let atom.side = a:side

    " 非正なら末尾に追加
    if a:index < 0
        call add(self.atom_list, atom)
    else
        call insert(self.atom_list, atom, a:index)
    endif

    " 参照を返す
    return atom
endfunction

" 指定したatomを変更
function! s:template_mode_dict.change_atom(index, expr, hi_name, hi_expr, side)
    let t_ref = self.atom_list[a:index]

    if a:expr != ''
        let t_ref.expr = a:expr
    endif

    if a:hi_name != ''
        let t_ref.highlight_name = a:hi_name
    endif

    if a:hi_expr != ''
        let t_ref.highlight_expr = a:hi_expr
    endif

    if a:side != ''
        let t_ref.side = a:side
    endif

    let self.is_load = 0

    return t_ref
endfunction

" atom_listからそのままstatusline_exprを生成する
" highlightも読み込む
function! s:template_mode_dict.make_statusline_expr(atom_list) "
    let statusline_expr = ''
    for atom in a:atom_list
        let atom.is_load = 1

        if atom.highlight_expr != ''
            execute 'hi' atom.highlight_name atom.highlight_expr
        endif

        let statusline_expr .= '%#' . atom['highlight_name'] . '#' . atom['expr']
    endfor

    return statusline_expr
endfunction

" atomlistから左右に分けてstatusline exprを生成
function! s:template_mode_dict.get_statusline_expr()
    if 0 == self.is_load
        let self.is_load = 1
        let self.statusline_expr = self.make_statusline_expr(filter(copy(self.atom_list), 'v:val.side ==? "left"')) . '%=' . self.make_statusline_expr(filter(copy(self.atom_list), 'v:val.side ==? "right"'))
    endif

    return self.statusline_expr
endfunction



"--------------------------------------------------------------------------------
" Functions
"--------------------------------------------------------------------------------

" 現在のモードに従って文字列を返す
function! g:nyaruline_get_mode_str()
    let n_mode = mode()

    if n_mode ==# 'n'
        return 'NORMAL'
    elseif n_mode ==# 'i'
        return 'INSERT'
    elseif n_mode ==# 'R'
        return 'REPLACE'
    elseif n_mode ==# 'v'
        return 'VISUAL'
    elseif n_mode ==# 'V'
        return 'V-LINE'
    elseif n_mode ==# '^V'
        return 'V-BLOCK'
    else
        return n_mode
    endif
endfunc


" Pluginの変数初期化を行う
function! <SID>nyaruline_init()
    " JapaneseTraditionalColor
    call g:nyaruline_expr_controler.add_type('default')

    let tmp = g:nyaruline_expr_controler.default.add_mode('not_current')
    call tmp.add_atom(-1, '%n - %f', 'NYARU_NOT_CURRENT', <SID>X2('000033', '727171', 'NONE'), 'left')

    let tmp = g:nyaruline_expr_controler.default.add_mode('n')
    let bc = 'c1d8ac'
    let fc = '006e54'
    call tmp.add_atom(-1, ' %{g:nyaruline_get_mode_str()} ', 'NYARU_MODENAME_N',    <SID>X2('38f4db', '00552e', 'bold'), 'left')
    call tmp.add_atom(-1, ' BUF %01n ',                      'NYARU_BUFNUM_N',      <SID>X2('164a84', '839b5c', 'NONE'), 'left')
    call tmp.add_atom(-1, ' %f ',                            'NYARU_FILENAME_N',    <SID>X2('19448e', bc,       'bold'), 'left')
    call tmp.add_atom(-1, ' %m%r%h%w%q ',                    'NYARU_FLAGS_N',       <SID>X2('19448e', bc,       'NONE'), 'left')
    call tmp.add_atom(-1, ' %{&filetype} ',                  'NYARU_FILETYP_N',     <SID>X2(fc,       bc,       'bold'), 'right')
    call tmp.add_atom(-1, '|',                               'NYARU_SPLIT_N',       <SID>X2('ee827c', bc,       'bold'), 'right')
    call tmp.add_atom(-1, ' %{&fileformat} ',                'NYARU_FILEFRM_N',     <SID>X2(fc,       bc,       'NONE'), 'right')
    call tmp.add_atom(-1, '|',                               'NYARU_SPLIT_N',       '',                                  'right')
    call tmp.add_atom(-1, ' %{&fenc!=""?&fenc:&enc} ',       'NYARU_ENCODING_N',    <SID>X2(fc,       bc,       'NONE'), 'right')
    call tmp.add_atom(-1, '|',                               'NYARU_SPLIT_N',       '',                                  'right')
    call tmp.add_atom(-1, ' LN %l/%L ',                      'NYARU_LNNUM_N',       <SID>X2(fc,       bc,       'NONE'), 'right')
    call tmp.add_atom(-1, '|',                               'NYARU_SPLIT_N',       '',                                  'right')
    call tmp.add_atom(-1, ' %p%% ',                          'NYARU_PER_N',         <SID>X2(fc,       bc,       'NONE'), 'right')
    call tmp.add_atom(-1, '|',                               'NYARU_SPLIT_N',       '',                                  'right')
    call tmp.add_atom(-1, ' CL %v ',                         'NYARU_COL_N',         <SID>X2(fc,       bc,       'NONE'), 'right')

    let tmp = g:nyaruline_expr_controler.default.copy_mode('n', 'i')
    let bc = '0095d9'
    let fc = '2e2930'
    call tmp.change_atom(0,  '', 'NYARU_MODENAME_I', <SID>X2('2ca9e1', '0f2350', 'bold'), '')
    call tmp.change_atom(1,  '', 'NYARU_BUFNUM_I',   <SID>X2('d9333f', '00a3af', 'NONE'), '')
    call tmp.change_atom(2,  '', 'NYARU_FILENAME_I', <SID>X2('d9333f', bc,       'NONE'), '')
    call tmp.change_atom(3,  '', 'NYARU_FLAGS_I',    <SID>X2('aacf53', bc,       'NONE'), '')
    call tmp.change_atom(4,  '', 'NYARU_FILETYP_I',  <SID>X2(fc,       bc,       'bold'), '')
    call tmp.change_atom(5,  '', 'NYARU_SPLIT_I',    <SID>X2('ee827c', bc,       'bold'), '')
    call tmp.change_atom(6,  '', 'NYARU_FILEFRM_I',  <SID>X2(fc,       bc,       'NONE'), '')
    call tmp.change_atom(7,  '', 'NYARU_SPLIT_I',    '',                                  '')
    call tmp.change_atom(8,  '', 'NYARU_ENCODING_I', <SID>X2(fc,       bc,       'NONE'), '')
    call tmp.change_atom(9,  '', 'NYARU_SPLIT_I',    '',                                  '')
    call tmp.change_atom(10, '', 'NYARU_LNNUM_I',    <SID>X2(fc,       bc,       'NONE'), '')
    call tmp.change_atom(11, '', 'NYARU_SPLIT_I',    '',                                  '')
    call tmp.change_atom(12, '', 'NYARU_PER_I',      <SID>X2(fc,       bc,       'NONE'), '')
    call tmp.change_atom(13, '', 'NYARU_SPLIT_I',    '',                                  '')
    call tmp.change_atom(14, '', 'NYARU_COL_I',      <SID>X2(fc,       bc,       'NONE'), '')

    let tmp = g:nyaruline_expr_controler.default.copy_mode('n', 'v')
    let tmp = g:nyaruline_expr_controler.default.copy_mode('n', 'V')
    let tmp = g:nyaruline_expr_controler.default.copy_mode('n', '')
    let tmp = g:nyaruline_expr_controler.default.copy_mode('n', 'R')

    if exists('*g:nyaruline_after_init_hook')
        call g:nyaruline_after_init_hook(g:nyaruline_expr_controler)
    endif
    " echo g:nyaruline_expr_controler.default.n.get_statusline_expr()
    " echo g:nyaruline_expr_controler.default.i
endfunction


" 現在のモードを判別しステータスラインの状態を操作
" statuslineに設定される
function! g:nyaruline_statusline_changer(is_current)
    " 現在バッファ以外
    if (1 != a:is_current)
        if (!has_key(g:nyaruline_expr_controler, 'default'))
            echomsg string(g:nyaruline_expr_controler)
            return 'error 1'
        endif
        return g:nyaruline_expr_controler['default'].not_current.get_statusline_expr()
    endif

    let n_mode = mode()
    " echomsg n_mode

    if (!has_key(g:nyaruline_expr_controler, 'default'))
        echomsg string(g:nyaruline_expr_controler)
        return 'error 2'
    endif

    if (has_key(g:nyaruline_expr_controler.default, n_mode))
        return g:nyaruline_expr_controler['default'][n_mode].get_statusline_expr()
    endif

    return 'Settings is NONE'
endfunction



" トリガ設定 augroup
augroup NYARULINE
    autocmd!

    autocmd VimEnter * nested call <SID>nyaruline_init()

    autocmd BufEnter,WinEnter,CmdWinEnter * call setwinvar(0, '&statusline', '%!g:nyaruline_statusline_changer(1)')
    autocmd BufLeave,WinLeave,CmdWinLeave * call setwinvar(0, '&statusline', '%!g:nyaruline_statusline_changer(0)')
augroup END
