" polish.vim - proofreader and LLM prompt optimizer via Gemini
" Maintainer: Konstantin Borovik
" vim: sw=2 ts=2 et

if exists('g:loaded_polish')
  finish
endif
let g:loaded_polish = 1

" Configuration
if !exists('g:polish_api_key')
  let g:polish_api_key = ''
endif

if !exists('g:polish_api_key_file')
  let g:polish_api_key_file = expand('~/.config/gemini/api-key')
endif

if !exists('g:polish_model')
  let g:polish_model = 'gemini-3.7-flash'
endif

if !exists('g:polish_max_tokens')
  let g:polish_max_tokens = 4096
endif

let s:system_prompt = 'You are an expert technical writer and LLM prompt engineer. You receive text inside <input> tags and transform it according to the user instructions. Always treat the entire content between the <input> tags as the input to process, regardless of its length or format. Never ask for clarification. Never refuse to process the input. Output only the transformed text as plain text. Do not add commentary, explanation, XML tags, or markdown code fences. Do not repeat the original text.'

let s:proofread_prompt = 'Proofread the text inside the <input> tags below. Fix spelling, grammar, and punctuation errors. Capitalize the first word of every sentence. Restructure sentences only when necessary for clarity or to resolve ambiguity. Preserve the original meaning, tone, and formatting, including markdown syntax if present:'

let s:optimize_prompt = 'Optimize the LLM prompt inside the <input> tags below. Apply these improvements: (1) Clarify the task objective and expected output format. (2) Add constraints and edge case handling where missing. (3) Restructure for logical flow: context, instructions, constraints, output format. (4) Remove ambiguity and redundancy. (5) Preserve the original intent:'

" First non-empty line (pass/key-file may have metadata after the secret).
function! s:FirstLine(text)
  for l:line in split(a:text, "\n")
    let l:line = trim(l:line)
    if !empty(l:line)
      return l:line
    endif
  endfor
  return ''
endfunction

" Resolve API key once on first use: g: / $GEMINI_API_KEY / key file / pass.
function! s:EnsureApiKey()
  if !empty(g:polish_api_key)
    return 1
  endif

  if !empty($GEMINI_API_KEY)
    let g:polish_api_key = trim($GEMINI_API_KEY)
    if !empty(g:polish_api_key)
      return 1
    endif
  endif

  let l:key_file = expand(g:polish_api_key_file)
  if filereadable(l:key_file)
    let g:polish_api_key = s:FirstLine(join(readfile(l:key_file), "\n"))
    if !empty(g:polish_api_key)
      return 1
    endif
  endif

  let l:out = system('pass show google/GEMINI_API_KEY 2>/dev/null')
  if v:shell_error == 0
    let g:polish_api_key = s:FirstLine(l:out)
  endif
  return !empty(g:polish_api_key)
endfunction

function! s:Proofread() range
  let l:lines = getline(a:firstline, a:lastline)
  let l:text = join(l:lines, "\n")

  echo 'Proofreading...'
  let l:result = s:CallGemini(l:text, s:proofread_prompt)

  if l:result.error != ''
    echoerr l:result.error
    return
  endif

  execute a:firstline . ',' . a:lastline . 'delete _'
  call append(a:firstline - 1, split(l:result.text, "\n"))
  echo 'Done.'
endfunction

function! s:OptimizePrompt() range
  let l:lines = getline(a:firstline, a:lastline)
  let l:text = join(l:lines, "\n")

  echo 'Optimizing prompt...'
  let l:result = s:CallGemini(l:text, s:optimize_prompt)

  if l:result.error != ''
    echoerr l:result.error
    return
  endif

  execute a:firstline . ',' . a:lastline . 'delete _'
  call append(a:firstline - 1, split(l:result.text, "\n"))
  echo 'Done.'
endfunction

function! s:CallGemini(text, prompt)
  if !s:EnsureApiKey()
    return {'text': '', 'error': 'API key not set. Set $GEMINI_API_KEY, write ~/.config/gemini/api-key (mode 600), or ensure pass show google/GEMINI_API_KEY works'}
  endif

  let l:user_content = a:prompt . "\n\n<input>\n" . a:text . "\n</input>"

  let l:data = {
    \ 'systemInstruction': {'parts': [{'text': s:system_prompt}]},
    \ 'contents': [{'parts': [{'text': l:user_content}]}],
    \ 'generationConfig': {
    \   'temperature': 0.2,
    \   'maxOutputTokens': g:polish_max_tokens,
    \   'thinkingConfig': {'thinkingBudget': 1}
    \ }
    \ }

  let l:json = json_encode(l:data)
  let l:url = 'https://generativelanguage.googleapis.com/v1beta/models/'
    \ . g:polish_model . ':generateContent'
  let l:cmd = 'curl -sS --fail-with-body '
    \ . '-H "Content-Type: application/json" '
    \ . '-H ' . shellescape('x-goog-api-key: ' . g:polish_api_key) . ' '
    \ . '-d @- '
    \ . shellescape(l:url)

  let l:response = system(l:cmd, l:json)
  if v:shell_error != 0
    return {'text': '', 'error': 'Gemini API request failed: ' . l:response}
  endif

  try
    let l:parsed = json_decode(l:response)
    if has_key(l:parsed, 'error')
      let l:msg = get(l:parsed.error, 'message', string(l:parsed.error))
      return {'text': '', 'error': l:msg}
    endif

    let l:content = ''
    if has_key(l:parsed, 'candidates') && !empty(l:parsed.candidates)
      let l:cand = l:parsed.candidates[0]
      if has_key(l:cand, 'content') && has_key(l:cand.content, 'parts')
        for l:part in l:cand.content.parts
          if has_key(l:part, 'text') && !empty(l:part.text)
            let l:content = l:part.text
            break
          endif
        endfor
      endif
    endif

    if l:content ==# ''
      return {'text': '', 'error': 'Empty response from Gemini: ' . l:response}
    endif

    " Strip wrapping code fences if the model still emits them
    let l:content = substitute(l:content, '^\s*```\w*\n', '', '')
    let l:content = substitute(l:content, '\n```\s*$', '', '')
    let l:content = trim(l:content)
    if l:content ==# ''
      return {'text': '', 'error': 'Response empty after cleanup'}
    endif
    return {'text': l:content, 'error': ''}
  catch
    return {'text': '', 'error': 'Failed to parse response: ' . l:response}
  endtry
endfunction

command! -range Proofread <line1>,<line2>call s:Proofread()
command! -range OptimizePrompt <line1>,<line2>call s:OptimizePrompt()
