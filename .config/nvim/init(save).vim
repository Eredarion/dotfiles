set runtimepath+=~/.vim_runtime

set autowrite
nnoremap <C-c> :!g++ -std=c++11 % -Wall -g -o %.out && ./%.out<CR>

source ~/.vim_runtime/vimrcs/basic.vim
source ~/.vim_runtime/vimrcs/filetypes.vim
source ~/.vim_runtime/vimrcs/plugins_config.vim
source ~/.vim_runtime/vimrcs/extended.vim
hi Normal guibg=NONE ctermbg=NONE

try
source ~/.vim_runtime/my_configs.vim
catch
endtry