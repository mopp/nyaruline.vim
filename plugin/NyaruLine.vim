" モード名 ファイル名       改行タイプ 文字コード ファイルタイプ 現在のパーセンテージ 行位置と列位置

" TODO:毎回定義するのはあれなので、初めてそのモードに入った時にだけハイライトを定義する
" NYARU_NORMAL_MODENAMEみたいなハイライト名にする
" それを設定する構造は 辞書型を使用
" 初回起動フラグ用の辞書を用意しておくと良いとおもわれ
" 加えて、別の辞書ファイルとして特定のバッファ名に対するハイライトやステータスラインを用意

" キャッシュを使うか使わないか


" 存在するなら読み込み済みなのでfinish
if exists('g:loaded_NyaruLine') || 1 == &compatible
    " finish
endif
let g:loaded_NyaruLine = 1



" Setting Color Functions {{{

" returns an approximate grey index for the given grey level {{{
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
" }}}


" returns the actual grey level represented by the grey index {{{
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

" }}}


" returns the palette index for the given grey index {{{
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
" }}}


" returns an approximate color index for the given color level {{{
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
" }}}


" returns the actual color level for the given color index {{{
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
" }}}


" returns the palette index for the given R/G/B color indices {{{
function! <SID>rgb_color(x, y, z)
    if &t_Co == 88
        return 16 + (a:x * 16) + (a:y * 4) + a:z
    else
        return 16 + (a:x * 36) + (a:y * 6) + a:z
    endif
endfun
" }}}


" returns the palette index to approximate the given R/G/B color levels {{{
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
" }}}


" returns the palette index to approximate the 'rrggbb' hex string {{{
function! <SID>rgb(rgb)
    let l:r = ("0x" . strpart(a:rgb, 0, 2)) + 0
    let l:g = ("0x" . strpart(a:rgb, 2, 2)) + 0
    let l:b = ("0x" . strpart(a:rgb, 4, 2)) + 0

    return <SID>color(l:r, l:g, l:b)
endfun
" }}}


" sets the highlighting for the given group {{{
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
" }}}

" }}}



" Variables {{{

" ステータスライン書式
let g:nyaruline_mode_exprs = {}

" ハイライト
let g:nyaruline_mode_highlights = {}

" リストからステータスラインを生成
let g:nyaruline_atom_list = []

" atomリストとロードチェックを持つ
let g:nyaruline_mode_dict = {}

" keyが特別扱いするバッファ名で要素はmode_dictのようなものをもつ
" defaultを標準で それ以外を特殊にする？
" types - modes - atoms
let g:nyaruline_expr_controler = {
            \ 'types' : {},
            \ }
" }}}


" modeを持つtypeを追加
" type名でバッファ名を指定する
function! g:nyaruline_expr_controler.add_type(name, mode_dict) " {{{
    let self.types[a:name] = a:mode_dict
endfunction
" }}}


" atomを追加
function! g:nyaruline_expr_controler.add_atom(type, mode, index, expr, hi_name, hi_expr, side) "{{{
    let atom = {}
    let atom.is_load = 0
    let atom.expr = a:expr
    let atom.highlight_name = a:hi_name
    let atom.highlight_expr = a:hi_expr
    let atom.side = a:side

    call insert(self[a:type][a:mode], atom, a:index)
endfunction
" }}}


" atom_listからそのままstatusline_exprを生成する
" highlightも読み込む FIXME
function! g:nyaruline_expr_controler.make_statusline_expr(atom_list) "{{{
    let statusline_expr = ''
    for atom in a:atom_list
        let atom.is_load = 1
        execute 'hi' atom.highlight_name atom.highlight_expr

        let statusline_expr .= '%#' . atom['highlight_name'] . '#' . atom['expr']
    endfor

    return statusline_expr
endfunction
" }}}


" atomlistから左右に分けてstatusline exprを生成
function! g:nyaruline_expr_controler.get_statusline_expr(type, mode) "{{{
    return self.make_statusline_expr(filter(copy(self[a:type][a:mode]), 'v:val.side ==? "left"')) . '=' . self.make_statusline_expr(filter(copy(self[a:type][a:mode]), 'v:val.side ==? "right"'))
endfunction
" }}}


" 辞書に追加{{{
function! s:add_mode_dict(key, mode_configs)
    " TODO : チェック入れる
    let g:nyaruline_mode_dict[key] = a:mode_configs
endfunction
" }}}


" Pluginの変数初期化を行う {{{
function! g:nyaruline_init()
    " 各モードラインの標準設定
    let g:nyaruline_mode_exprs.not_current = '%(%#NYARU_DISABLE#%n - %f%)'
    let g:nyaruline_mode_exprs.n = '%#NYARU_MODENAME_n# NORMAL %#NYARU_FILENAME# %f %#NYARU_FLAGS# %m%r%h%w%q %= %< %#NYARU_ENCODING#%{&fenc!=""?&fenc:&enc} %#NYARU_FILL#%{&fileformat} %y %03c%%%03l %02n@BN --%p%%-- '
    let g:nyaruline_mode_exprs.i = '%#NYARU_MODENAME_i# INSERT %#NYARU_FILENAME# %f %#NYARU_FLAGS# %m%r%h%w%q %= %< %{&fenc!=""?&fenc:&enc} %{&fileformat} %y %03c%%%03l %02n@BN --%p%%-- '

    " ハイライト設定 - JapaneseTraditionalColor
    let g:nyaruline_mode_highlights.not_current = {}
    let g:nyaruline_mode_highlights.not_current.is_load = 0
    let g:nyaruline_mode_highlights.not_current.disable = <SID>X('NYARU_DISABLE', '000033', '727171', 'NONE')
    let g:nyaruline_mode_highlights.n = {}
    let g:nyaruline_mode_highlights.n.is_load = 0
    let g:nyaruline_mode_highlights.n.modename = <SID>X('NYARU_MODENAME_n', '38b48b', '00552e', 'bold')
    let g:nyaruline_mode_highlights.n.flags =    <SID>X('NYARU_FLAGS', 'd9333f', '000b00', 'NONE')
    let g:nyaruline_mode_highlights.n.filename = <SID>X('NYARU_FILENAME', 'aacf53', '1f3134', 'NONE')
    let g:nyaruline_mode_highlights.n.encoding = <SID>X('NYARU_ENCODING', '82ae46', '000b00', 'NONE')
    let g:nyaruline_mode_highlights.n.fill =     <SID>X('NYARU_FILL', '00a3af', '000b00', 'NONE')
    let g:nyaruline_mode_highlights.i = {}
    let g:nyaruline_mode_highlights.i.is_load = 0
    let g:nyaruline_mode_highlights.i.modename = <SID>X('NYARU_MODENAME_i', '2ca9e1', '0f2350', 'bold')
    let g:nyaruline_mode_highlights.i.flags =    <SID>X('NYARU_FLAGS', 'd9333f', '16160e', 'NONE')
    let g:nyaruline_mode_highlights.i.filename = <SID>X('NYARU_FILENAME', 'd9333f', '16160e', 'NONE')
    let g:nyaruline_mode_highlights.i.fill =     <SID>X('NYARU_FILL', '180614', '16160e', 'NONE')
endfunction
" call g:initNyaruLine() " For Debug
" }}}


" 各モードのハイライトを設定する TODO : 検証用関数作成 {{{
function! g:setHighlightEachMode(highlightList)
    for e in items(a:highlightList)

        " 読み込みフラグON
        if e[0] ==? 'is_load'
            let a:highlightList.is_load = 1
            continue
        endif

        execute e[1]
    endfor
endfunction
" }}}


" 現在のモードを判別しステータスラインの状態を操作 {{{
" statuslineに設定される
function! g:nyaruline_get_stasusline_expr(is_current)
    " echo 'Detect ! mode = '.mode().' Buffer is '.bufname('%')

    " 現在バッファ以外
    if (1 != a:is_current)
        if 0 == g:nyaruline_mode_highlights.not_current.is_load
            call g:setHighlightEachMode(g:nyaruline_mode_highlights.not_current)
        endif
        return g:nyaruline_mode_exprs.not_current
    endif

    let n_mode = mode()

    if (has_key(g:nyaruline_mode_exprs, n_mode) && has_key(g:nyaruline_mode_exprs, n_mode))
        if 0 == g:nyaruline_mode_highlights[n_mode].is_load
            call g:setHighlightEachMode(g:nyaruline_mode_highlights[n_mode])
        endif
        return g:nyaruline_mode_exprs[n_mode]
    endif

    return 'Settings is NONE'
endfunction
" }}}


" トリガ設定 augroup {{{
augroup NYARULINE
    autocmd!

    " VimFilerにてエラー
    autocmd VimEnter * nested call g:nyaruline_init()

    autocmd BufEnter,WinEnter,CmdWinEnter * call setwinvar(0, '&statusline', '%!g:nyaruline_get_stasusline_expr(1)')
    autocmd BufLeave,WinLeave,CmdWinLeave * call setwinvar(0, '&statusline', '%!g:nyaruline_get_stasusline_expr(0)')
augroup END
" }}}


" vim: set foldmethod=marker:
