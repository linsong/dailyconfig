use strict;
use Irssi 20020101.0250 ();
use vars qw($VERSION %IRSSI); 

$VERSION = "1";
%IRSSI = (
    authors     => "Timo Sirainen, Ian Peters",
    contact	=> "tss\@iki.fi", 
    name        => "Nick Color",
    description => "assign a different color for each nick",
    license	=> "Public Domain",
    url		=> "http://irssi.org/",
    changed	=> "2002-03-04T22:47+0100"
);

sub cmd_help1 {
    Irssi::print('===================================================================');  
    Irssi::print('Irssi\'s colors that you can use in text formats, hilights, etc. :');
    Irssi::print(' ');
    Irssi::print('                             text            text              background');
    Irssi::print('   ---------------------------------------------------------------------');
    Irssi::print('   %%k     %%K     %%0          %kblack%n           %Kdark grey%n         %0black%n');
    Irssi::print('   %%r     %%R     %%1          %rred%n             %Rbold red%n          %1red%n');
    Irssi::print('   %%g     %%G     %%2          %ggreen%n           %Gbold green%n        %2green%n');
    Irssi::print('   %%y     %%Y     %%3          %yyellow%n          %Ybold yellow%n       %3yellow%n');
    Irssi::print('   %%b     %%B     %%4          %bblue%n            %Bbold blue%n         %4blue%n');
    Irssi::print('   %%m     %%M     %%5          %mmagenta%n         %Mbold magenta%n      %5magenta%n');
    Irssi::print('   %%p     %%P                 %pmagenta (think: purple)');
    Irssi::print('   %%c     %%C     %%6          %ccyan%n            %Cbold cyan%n         %6cyan%n');
    Irssi::print('   %%w     %%W     %%7          %wwhite%n           %Wbold white%n        %K%7white%n');
    Irssi::print('   %%n     %%N                 Changes the color to "default color", removing');
    Irssi::print('                             all other coloring and formatting. %%N is always');
    Irssi::print('                             the terminal\'s default color. %%n is usually too,');
    Irssi::print('                             except in themes it changes to "previous color",');
    Irssi::print('                             ie. hello = "%%Rhello%%n" and "%%G{hello} world"');
    Irssi::print('                             would print hello in red, and %%n would turn back');
    Irssi::print('                             into %%G making world green.');
    Irssi::print('   %%F                        Blinking on/off (think: flash)');
    Irssi::print('   %%U                        Underline on/off');
    Irssi::print('   %%8                        Reverse on/off');
    Irssi::print('   %%9      %%_                Bold on/off');
    Irssi::print('   %%:                        Insert newline');
    Irssi::print('   %%|                        Marks the indentation position');
    Irssi::print('   %%#                        Monospace font on/off (useful with lists and GUI)');
    Irssi::print('   %%%                        A single %%');
}

sub cmd_help2 {
    Irssi::print('==============================================================');  
    Irssi::print('MIRC colors that you can use when writing text to channel:');
    Irssi::print('               foreground (fg)     background (bg)');
    Irssi::print('   -------------------------------------------------------');
    Irssi::print('    0          %Wwhite%n               light gray   + blinking fg');
    Irssi::print('    1          %Kblack%n               black');
    Irssi::print('    2          %Bblue%n                %4blue%n');
    Irssi::print('    3          %Ggreen%n               %2green%n');
    Irssi::print('    4          light red           %1%Fred          + blinking fg%n');
    Irssi::print('    5          %Rred%n                 %1red%n');
    Irssi::print('    6          %Mmagenta (purple)%n    %5magenta%n');
    Irssi::print('    7          orange              orange');
    Irssi::print('    8          %Yyellow%n              %Forange       + blinking fg%n');
    Irssi::print('    9          light green         %2%Fgreen        + blinking fg%n');
    Irssi::print('    10         %Ccyan%n                cyan         ');
    Irssi::print('    11         light cyan          %6%Fcyan         + blinking fg%n');
    Irssi::print('    12         light blue          %4%Fblue         + blinking fg%n');
    Irssi::print('    13         light magenta       %5%Fmagenta      + blinking fg%n');
    Irssi::print('    14         gray                %Fblack        + blinking fg%n ');
    Irssi::print('    15         light gray          light gray');
    Irssi::print(' ');
    Irssi::print('These colors may differ depending on your terminal. In particular');
    Irssi::print('the meaning for background may be the same as for the foreground');
    Irssi::print('(bright colors, no blinking), and orange often looks like brown or');
    Irssi::print('dark yellow.');
    Irssi::print('How to use these colors (\'#\' means a number as MIRC color code):');
    Irssi::print(' ');
    Irssi::print('<Ctrl>-b        set bold');
    Irssi::print('<Ctrl>-c#[,#]   set foreground and optionally background color');
    Irssi::print('<Ctrl>-o        reset all formats to plain text');
    Irssi::print('<Ctrl>-v        set inverted color mode');
    Irssi::print('<Ctrl>-_        set underline');
    Irssi::print('<Ctrl>-7        same as <Ctrl>-_');
    Irssi::print(' ');
    Irssi::print('To reset a mode set it again, f.e.');
    Irssi::print('  <Ctrl-C>3<Ctrl-V>FOO<Ctrl-V>BAR');
    Irssi::print('creates black on green FOO followed by a green on black BAR');
}

Irssi::command_bind('colorhelp1', 'cmd_help1');
Irssi::command_bind('colorhelp2', 'cmd_help2');
