if !has("python")
    finish
endif

function! Blog()
    let tmpfile = tempname() . ".blogger"
    execute "e! " . tmpfile
python << EOF
vim.current.buffer[:] = None
vim.current.buffer.append("")
vim.current.buffer.append("")
vim.current.buffer.append("@@LABELS@@ ")
vim.command("normal gg")
vim.command("map j gj")
vim.command("map k gk")
EOF
endfunction
:command! Blog :call Blog()
