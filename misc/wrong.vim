finish

" Pluginの変数など初期化
function! g:initNyaruLine()
    " 各モードごとの設定する文字列
    let g:NyaruLine_Str = {}
    let g:NyaruLine_Str.i = ''
    let g:NyaruLine_Str.n = ''

    let g:NyaruLine_Highlights = {}

    let g:NyaruLine_Highlights.disable = {}
    let g:NyaruLine_Highlights.disable.isLoad = 0
    let g:NyaruLine_Highlights.disable.hi = []

    let g:NyaruLine_Highlights.i = {}
    let g:NyaruLine_Highlights.i.isLoad = 0
    let g:NyaruLine_Highlights.i.hi = []

    let g:NyaruLine_Highlights.n = {}
    let g:NyaruLine_Highlights.n.isLoad = 0
    let g:NyaruLine_Highlights.n.hi = []
endfunction


" 指定されたモードから文字列を返す
function! g:generateLineStrByMode(modeChar)

endfunction


function! g:getModeStatusLine(isCurrent)
    " echo 'Detect ! mode = '.mode().' Buffer is '.bufname('%')

    " 現在バッファ以外
    if (!a:isCurrent)
        call g:setHighlightEachMode(g:NyaruLine_Mode_Highlight['notCurrent'])
        return g:NyaruLine_Mode_Str.notCurrent
    endif

    " TODO:特定バッファの判別 正規表現を使用する
    " if (bufname('%'))
    " endif

    let nMode = mode()

    " そのモードのキーが存在すれば表示
    if (has_key(g:NyaruLine_Mode_Str, nMode) && has_key(g:NyaruLine_Mode_Highlight, nMode))
        " TODO:ハイライトを設定したかどうかを確認する
        return 
    endif

    return 'Settings is NONE'
endfunction


augroup NYARULINE
    autocmd!

    autocmd VimEnter,ColorScheme * call g:initNyaruLine()

    autocmd BufEnter,WinEnter,CmdWinEnter * call setwinvar(0, '&statusline', '%!g:getModeStatusLine(1)')
    autocmd BufLeave,WinLeave,CmdWinLeave * call setwinvar(0, '&statusline', '%!g:getModeStatusLine(0)')
augroup END
