
if has('ruby')
  let rbfile = expand("<sfile>:p:h") . "/ehhack.rb"
  execute "ruby load '" . rbfile . "'"
  map <silent> ,t :ruby EhHack.test<CR>
  map <silent> ,d :ruby EhHack.debug<CR>
  if has('autocmd')
    augroup ehhack
      au!
      autocmd BufNewFile,BufRead * ruby EhHack.setup_abbreviations
      autocmd BufNewFile *.cpp ruby EhHack.new_file
    augroup END
  endif
endif
