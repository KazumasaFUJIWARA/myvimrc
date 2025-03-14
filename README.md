# myvimrc
個人用のvimrc

## Gemini Vim 設定ファイル

### 概要

このVim設定ファイルは、外部APIとの対話を行うためのカスタム関数とマッピングを提供します。この機能を使って、Vimエディタ内で直接、テキスト入力の処理や強化されたテキスト操作、分析を行うことができます。

### 定義している関数

- GeminiFuncHelp(ft, funcname)
ftはソースのファイルタイプで,
ファイルタイプと関数名(実際は聞きたい箇所)
を指定することで, Geminiに問い合わせる

#### Key Bind
##### visual mode
- vnoremap <silent> <Leader>g :<C-u>call Gemininglishv()<CR>
選択範囲の英語を翻訳

- vnoremap <silent> <Leader>h :<C-u>call GeminiFuncHelp(&ft, join(getregion(getpos("v"), getpos("'>")),"\n"))<CR>
選択範囲をfile type毎にGemeiniで問い合わせ

##### normal mode
- nnoremap <silent> <Leader>g :<C-u>call Gemininglishn()<CR>
カーソル上の単語の英語を翻訳

- nnoremap <silent> <Leader>h :<C-u>call GeminiFuncHelp(&ft, expand('<cword>'))<CR>
カーソル上の単語をfile type毎にGeminiに問い合わせ

##### command
- command! -nargs=1 Gemini call GeminiChat(<q-args>)
