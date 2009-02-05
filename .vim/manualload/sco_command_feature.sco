____________________________________________________________________________________________________________________
SourceCodeObedience command feature
____________________________________________________________________________________________________________________
@ sco_command_feature.sco 1 / Content / ```content>>><<<
% command_setup:
>>> common commands
{
    echo "------------------------"
    echo "common commands executed"
    echo "------------------------"
}
<<<

____________________________________________________________________________________________________________________
/ Content /
____________________________________________________________________________________________________________________

@ sco_command_feature.sco 1 / Introduction / ```introduction>>><<<
@ sco_command_feature.sco 1 / Command ability / ```command ability>>><<<
@ sco_command_feature.sco 1 / Special keywords / ```special keywords>>><<<
@ sco_command_feature.sco 1 / Multi line commands / ```multi line commands>>><<<
@ sco_command_feature.sco 1 / Common Commands / ```common commands>>><<<
@ sco_command_feature.sco 1 / Force mark jump / ```force mark jump>>><<<

____________________________________________________________________________________________________________________
/ Introduction /
____________________________________________________________________________________________________________________

Help file wasn't created yet. That's why new feature will be described below in that file.
Please take a look and fill free to post questions to google.group ( link from www.vim.org/scripts/script.php?script_id=1638 )

As you know .sco file can has 'smart marks' -- folded lines with links to some file place. 
Smart marks can has caption like mark below 'introduction'. After pressing <CR> on mark you'll be moved to appropriate place of file.
@ sco_command_feature.sco 1 / Introduction / ```introduction>>><<<

@ sco_command_feature.sco 1 / Content / ```content>>><<<

____________________________________________________________________________________________________________________
/ Command ability /
____________________________________________________________________________________________________________________

As I mentioned default behaviour for <CR> on smart mark is moving to place.
Now behavior can be changed with new command ability.
Try link below -- it is standard behaviour.
@ sco_command_feature.sco 1 / Command ability / ```smart mark standard behaviour>>><<<

* echo "File name = _file_"
Now Try that link
@ sco_command_feature.sco 1 / Command ability / ```link with command behaviour>>><<<

What happened?
Instead of move to mark command in line 28 was executed "* echo ... "

* echo "File name = _file_"

Now Try that link again
@ sco_command_feature.sco 1 / Command ability / ```link with command behaviour>>><<<

We pressed on mark. Tried to find command but met empty line.
Execute standard jump to mark instead of executing vim command.

* echo "File name = _file_" | echo "pattern to search = _pattern_" | echo "caption = _caption_"
Now Try that link again
@ sco_command_feature.sco 1 / Command ability / ```link with command behaviour>>><<<

Or That
* tabedit _file_
@ sco_command_feature.sco 1 / Command ability / ```link with command behaviour>>><<<

Be careful -- new tab opened.


@ sco_command_feature.sco 1 / Content / ```content>>><<<
____________________________________________________________________________________________________________________
/ Special keywords /
____________________________________________________________________________________________________________________

Did you see _file_, _pattern_ and _caption_ keyword inside vim command ?
_file_ substuted with mark file name
_pattern_ with pattern to search
_caption_ with text you see on sco buffer
@ sco_command_feature.sco 1 / Content / ```content>>><<<

____________________________________________________________________________________________________________________
/ Multi line commands /
____________________________________________________________________________________________________________________

Isn't convenient to write commands with '|' delimiter ?
Open line below with <CR>
>>>
{
    echo '_file_'
    echo '_pattern_'
    echo '_caption_'
}
<<<
now try to open link
@ sco_command_feature.sco 1 / Content / ```content>>><<<

To add stub multi line command use :Command

@ sco_command_feature.sco 1 / Content / ```content>>><<<

____________________________________________________________________________________________________________________
/ Common Commands /
____________________________________________________________________________________________________________________

Do you remember 
"common commands executed" line before any command executed or mark jumps?
* echo "test"
@ sco_command_feature.sco 1 / Content / ```link>>><<<

Before executing any command from smart mark common commands executed.
After every .sco buffer open common commands executed!
You can setup common commands here
@ sco_command_feature.sco 1 % command_setup: ```common commands setup>>><<<

For new .sco file you can specify common commands with 
    let g:sco_default_common_command=['echo 1', 'echo 2', 'echo 3']
in your vimrc file

@ sco_command_feature.sco 1 / Content / ```content>>><<<

____________________________________________________________________________________________________________________
/ Force mark jump /
____________________________________________________________________________________________________________________
Want to jump to mark but command present?
Press <C-Enter> or remap ForceEnter command in sco_keys.vim file

try link below with <CR> and with <C-CR>

* echo "test"
@ sco_command_feature.sco 1 / Content / ```link>>><<<

@ sco_command_feature.sco 1 / Content / ```content>>><<<
____________________________________________________________________________________________________________________
/ So what ? /
____________________________________________________________________________________________________________________

I didn't try to imagine all ways to use that. But I use three:

    _______________________________________________________________________________________________________________
     First -- review command
    _______________________________________________________________________________________________________________

before links(marks) to file I changed I put command

* tabedit _file_ | AWDiffMirrorFile

in common commands I setup alternate workspace variables

>>> common commands
{
    let g:aw_child_path = "....."
    let g:aw_parent_path = "......"
}
<<<

alternate_workspace.vim in www.vim.org

    _______________________________________________________________________________________________________________
    Second -- substitute commands
    _______________________________________________________________________________________________________________

I gather group of files to substitute to one place and
add substitute command

BigFoot
    BigFoot::eat()
>>> substitute example
{
    tabedit _file_
    %s/newexpr/oldexpr/c
    %s/BigFoot/big_foot/gc
}
<<<
@ sco_command_feature.sco 1     Second -- substitute commands ```press to start substitute>>><<<

Of course it is better not to substitute in current file. It is only for example
It is very convenient to have all common substitute commands near you - for example substitute command which 
add extra space after '(' and before ')' ( If you have such code convenience )
    _______________________________________________________________________________________________________________

    Third -- script executions. SQL ( script dbext.vim from www.vim.org )
    _______________________________________________________________________________________________________________


I had file with sql queries for my needs

select * from some_table_name
select * from another_table_name where some_id = 54

and then I check results with

* DBExecSQL _pattern_
header: test sql queries
  tags: sql, query
_______________________________________________________________________________________________________________
@ sco_command_feature.sco 1 select * from some_table_name ```select * from some_table_name>>><<<
@ sco_command_feature.sco 1 select * from another_table_name where some_id = 54 ```select * from another_table_name where some_id = 54>>><<<

@ sco_command_feature.sco 1 / Content / ```content>>><<<

