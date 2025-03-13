"{{{ GeminiChat
function! GeminiChat(querry)
	
	" APIキー（環境変数から取得する場合）
	let api_key = $GEMINII

	" API URL
	let url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=' . api_key

	" リクエストボディ
	let body = '{"contents":'
				\ . '[{"parts":[{'
				\ . '"text":"'
				\ . a:querry
				\ . '"}]}]}'

	" リクエストヘッダ
	let headers = ' -H "Content-Type: application/json"'

	" リクエスト
	let command = 'curl ' . url . headers . " -X POST -d '" . body ."' 2> /dev/null"

	" レスポンス
	let response = system(command)

	" responseの\nを改行に変換
	" 改行を表示するためには、\\nを\nに変換する必要がある
	let response = substitute(response, '\\n', '\n', 'g')

	" responseをJSONに変換
	let json = json_decode(response)
	echo json['candidates'][0]['content']['parts'][0]['text']
endfunction
"}}}

"{{{ Gemininglish
" 文字のリストを取得して、連結してapiにリクエストを送信する
function! Gemininglish(selected_texts)

	" selected_textsを連結
	let selected_text = ''
	for text in a:selected_texts
		" もし%で始まる行があれば、その行はコメントなので無視
		if text[0] == '%'
			continue
		endif
		let selected_text .= text
		let selected_text .= ' '
	endfor

	" APIキー（環境変数から取得する場合）
	let api_key = $GEMINII

	" API URL
	let url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=' . api_key

	" リクエストボディ
	let body = '{"contents":'
				\ . '[{"parts":[{'
				\ . '"text": "Correct English of the given sentence and respond the collection summary with Json. Do not mention about math formula, coding error, and anything about eqref, ref, and cite. Response is composed by {proposal, reason}. Reason part is written in Japanese. If there is nothing to modify, do not respond any : '
				\ . selected_text
				\ . '"}]}]}'

	" リクエストヘッダ
	let headers = ' -H "Content-Type: application/json"'

	" リクエスト
	let command = 'curl ' . url . headers . " -X POST -d '" . body ."' 2> /dev/null"

	" レスポンス
	let response = system(command)

	" responseの\nを改行に変換
	" 改行を表示するためには、\\nを\nに変換する必要がある
	let response = substitute(response, '\\n', '\n', 'g')

	" text内の```json```の中身を取得
	let json = matchstr(response, '```json\n\zs.*\ze\n```')
	" \"を"に変換
	let json = substitute(json, '\\"', '"', 'g')

	" jsonをパース
	let json = json_decode(json)

	" jsonが空ならば、終了
	if json == {}
		return
	endif

	" reasonをecho
	echo json['reason']

	" proposalをreturn
	return json['proposal']
	
endfunction
"}}}

" {{{ function! Gemininglishv()
function! Gemininglishv()
	" 選択されたテキストを取得
	let selected_texts = getregion(getpos("v"), getpos("'>"))

	let proposal = Gemininglish(selected_texts)

	" proposalが空ならば終了
	if proposal == ''
		return
	endif

	" 選択されたテキストの次の行にproposalを挿入
	normal! '>
	execute "normal! o\n" . proposal . "\n\<ESC>"
	
endfunction
" }}}

"{{{ function! Gemininglishn()
function! Gemininglishn()
	normal! (v)
	let selected_texts = getregion(getpos("v"), getpos("'>"))
	let proposal = Gemininglish(selected_texts)
	normal! v

	" proposalが空ならば終了
	if proposal == ''
		return
	endif

	execute "normal! O\n" . proposal . "\n\<ESC>"

endfunction
"}}}

"{{{ function! GeminiFuncHelp()
" 引数はファイルタイプと関数名
function! GeminiFuncHelp(ft, funcname)
	" APIキー（環境変数から取得する場合）
	let api_key = $GEMINII

	" API URL
	let url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=' . api_key

	" リクエストボディ
	let body = '{"contents":'
				\ . '[{"parts":[{'
				\ . '"text": "I am dealing with a ' . a:ft . ' file. Please explain the usage of <' . a:funcname . '> shortly in Japanese.'
				\ . '"}]}]}'

	" リクエストヘッダ
	let headers = ' -H "Content-Type: application/json"'

	" リクエスト
	let command = 'curl ' . url . headers . " -X POST -d '" . body ."' 2> /dev/null"

	" レスポンス
	let response = system(command)

	" responseの\nを改行に変換
	" 改行を表示するためには、\\nを\nに変換する必要がある
	let response = substitute(response, '\\n', '\n', 'g')

	" responseをJSONに変換
	let json = json_decode(response)
	echo json['candidates'][0]['content']['parts'][0]['text']
endfunction
"}}}

" visual modeで選択されたテキストを取得して、APIにリクエストを送信するmapping
vnoremap <silent> <Leader>g :<C-u>call Gemininglishv()<CR>

" normal modeで選択されたテキストを取得して、APIにリクエストを送信するmapping
nnoremap <silent> <Leader>g :<C-u>call Gemininglishn()<CR>
nnoremap <silent> <Leader>h :<C-u>call GeminiFuncHelp(&ft, expand('<cword>'))<CR>


":gemini XXXでcall GeminiChat('XXX')を実行するmapping
command! -nargs=1 Gemini call GeminiChat(<q-args>)
