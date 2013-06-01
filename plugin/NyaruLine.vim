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


" Pluginの変数初期化を行う {{{
function! g:initNyaruLine()
    set background=dark

    " 各モードラインの標準設定;w
    let g:NyaruLine_Mode_Str = {}
    let g:NyaruLine_Mode_Str.notCurrent = '%(%#NYARU_DISABLE#%n - %f%)'
    let g:NyaruLine_Mode_Str.n = '%#NYARU_MODENAME# %{expand("NORMAL")} %#NYARU_FILENAME# %f %#NYARU_FLAGS# %m%r%h%w%q %=%< %#NYARU_ENCODING#%{&fenc!=""?&fenc:&enc} %#NYARU_FILL#%{&fileformat} %y %03c%%%03l %02n@BN --%p%%-- '
    let g:NyaruLine_Mode_Str.i = '%#NYARU_MODENAME# %{expand("INSERT")} %#NYARU_FILENAME# %f %#NYARU_FLAGS# %m%r%h%w%q%= %< %{&fenc!=""?&fenc:&enc} %{&fileformat} %y %03c%%%03l %02n@BN --%p%%-- '

    " ハイライト設定 - JapaneseTraditionalColor
    let g:NyaruLine_Mode_Highlight = {}
    let g:NyaruLine_Mode_Highlight.notCurrent = {}
    let g:NyaruLine_Mode_Highlight.notCurrent.disable = <SID>X('NYARU_DISABLE', '000033', '727171', 'NONE')
    let g:NyaruLine_Mode_Highlight.n = {}
    let g:NyaruLine_Mode_Highlight.n.modename = <SID>X('NYARU_MODENAME', '38b48b', '00552e', 'bold')
    let g:NyaruLine_Mode_Highlight.n.flags =    <SID>X('NYARU_FLAGS', 'd9333f', '000b00', 'NONE')
    let g:NyaruLine_Mode_Highlight.n.filename = <SID>X('NYARU_FILENAME', 'aacf53', '1f3134', 'NONE')
    let g:NyaruLine_Mode_Highlight.n.encoding = <SID>X('NYARU_ENCODING', '82ae46', '000b00', 'NONE')
    let g:NyaruLine_Mode_Highlight.n.fill =     <SID>X('NYARU_FILL', '00a3af', '000b00', 'NONE')
    let g:NyaruLine_Mode_Highlight.i = {}
    let g:NyaruLine_Mode_Highlight.i.modename = <SID>X('NYARU_MODENAME', '2ca9e1', '0f2350', 'bold')
    let g:NyaruLine_Mode_Highlight.i.flags =    <SID>X('NYARU_FLAGS', 'd9333f', '16160e', 'NONE')
    let g:NyaruLine_Mode_Highlight.i.filename = <SID>X('NYARU_FILENAME', 'd9333f', '16160e', 'NONE')
    let g:NyaruLine_Mode_Highlight.i.fill =     <SID>X('NYARU_FILL', '180614', '16160e', 'NONE')

endfunction
" call g:initNyaruLine() " For Debug
" }}}


" 各モードのハイライトを設定する TODO : 検証用関数作成 {{{
function! g:setHighlightEachMode(highlightList)
    for e in values(a:highlightList)
        execute e
    endfor
endfunction
" }}}


" 現在のモードを判別しステータスラインの状態を操作 {{{
" statuslineに設定される
function! g:getModeStatusLine(isCurrent)
    " echo 'Detect ! mode = '.mode().' Buffer is '.bufname('%')

    " 現在バッファ以外
    if (!a:isCurrent)
        call g:setHighlightEachMode(g:NyaruLine_Mode_Highlight['notCurrent'])
        return g:NyaruLine_Mode_Str.notCurrent
    endif

    let nMode = mode()

    if (has_key(g:NyaruLine_Mode_Str, nMode) && has_key(g:NyaruLine_Mode_Highlight, nMode))
        call g:setHighlightEachMode(g:NyaruLine_Mode_Highlight[nMode])
        return g:NyaruLine_Mode_Str[nMode]
    endif

    return 'Settings is NONE'
endfunction
" }}}


" トリガ設定 augroup {{{
augroup NYARULINE
    autocmd!

    " VimFilerにてエラー
    autocmd VimEnter * nested call g:initNyaruLine()

    autocmd BufEnter,WinEnter,CmdWinEnter * call setwinvar(0, '&statusline', '%!g:getModeStatusLine(1)')
    autocmd BufLeave,WinLeave,CmdWinLeave * call setwinvar(0, '&statusline', '%!g:getModeStatusLine(0)')
augroup END
" }}}



" vim: set foldmethod=marker:
