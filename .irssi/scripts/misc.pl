use strict;
use List::Util 'shuffle';
use Irssi 20020101.0250 ();
use vars qw($VERSION %IRSSI); 

$VERSION = "1";
%IRSSI = (
    authors     => "Vincent Wang",
    contact	=> "linsong DOT qizi AT gmail DOT com", 
    name        => "misc commands",
    description => "misc commands that may make daily work easier ;)",
    license	=> "Public Domain",
    url		=> "Not avaiable yet",
    changed	=> "2008-03-05T14:22+0800"
);

sub cmd_help1 {
    Irssi::print( <<SCRIPTHELP_EOF
    
===================================================================  
Irssi's colors that you can use in text formats, hilights, etc. :
 
                             text            text              background
   ---------------------------------------------------------------------
   %%k     %%K     %%0          %kblack%n           %Kdark grey%n         %0black%n
   %%r     %%R     %%1          %rred%n             %Rbold red%n          %1red%n
   %%g     %%G     %%2          %ggreen%n           %Gbold green%n        %2green%n
   %%y     %%Y     %%3          %yyellow%n          %Ybold yellow%n       %3yellow%n
   %%b     %%B     %%4          %bblue%n            %Bbold blue%n         %4blue%n
   %%m     %%M     %%5          %mmagenta%n         %Mbold magenta%n      %5magenta%n
   %%p     %%P                 %pmagenta (think: purple)
   %%c     %%C     %%6          %ccyan%n            %Cbold cyan%n         %6cyan%n
   %%w     %%W     %%7          %wwhite%n           %Wbold white%n        %K%7white%n
   %%n     %%N                 Changes the color to "default color", removing
                             all other coloring and formatting. %%N is always
                             the terminal's default color. %%n is usually too,
                             except in themes it changes to "previous color",
                             ie. hello = "%%Rhello%%n" and "%%G{hello} world"
                             would print hello in red, and %%n would turn back
                             into %%G making world green.
   %%F                        Blinking on/off (think: flash)
   %%U                        Underline on/off
   %%8                        Reverse on/off
   %%9      %%_                Bold on/off
   %%:                        Insert newline
   %%|                        Marks the indentation position
   %%#                        Monospace font on/off (useful with lists and GUI)
   %%%                        A single %%
SCRIPTHELP_EOF
);
}

sub cmd_help2 {
    Irssi::print( <<SCRIPTHELP_EOF

==============================================================  
MIRC colors that you can use when writing text to channel:
               foreground (fg)     background (bg)
   -------------------------------------------------------
    0          %Wwhite%n               %Flight gray%n   + blinking fg
    1          %Kblack%n               black
    2          %Bblue%n                %4blue%n
    3          %Ggreen%n               %2green%n
    4          light red           %1%Fred%n          + blinking fg
    5          %Rred%n                 %1red%n
    6          %Mmagenta (purple)%n    %5magenta%n
    7          orange              orange
    8          %Yyellow%n              %Forange%n       + blinking fg
    9          light green         %2%Fgreen%n       + blinking fg
    10         %Ccyan%n                cyan         
    11         light cyan          %6%Fcyan%n         + blinking fg
    12         light blue          %4%Fblue%n         + blinking fg
    13         light magenta       %5%Fmagenta%n      + blinking fg
    14         gray                %Fblack%n        + blinking fg 
    15         light gray          light gray
 
These colors may differ depending on your terminal. In particular
the meaning for background may be the same as for the foreground
(bright colors, no blinking), and orange often looks like brown or
dark yellow.
How to use these colors ('#' means a number as MIRC color code):
 
<Ctrl>-b        set bold
<Ctrl>-c#[,#]   set foreground and optionally background color
<Ctrl>-o        reset all formats to plain text
<Ctrl>-v        set inverted color mode
<Ctrl>-_        set underline
<Ctrl>-7        same as <Ctrl>-_
 
To reset a mode set it again, f.e.
  <Ctrl-C>3<Ctrl-V>FOO<Ctrl-V>BAR
creates black on green FOO followed by a green on black BAR: %G%8FOO%8BAR%n
SCRIPTHELP_EOF
);
}

sub cmd_scrum {
    my ($data, $server, $witem) = @_;

    if (!$server || !$server->{connected}) {
      Irssi::print("Not connected to server");
      return;
    }

    my @names  = split(/[\s,:]/, $data);
    my $report_order = join(' ', shuffle(@names));
    my $msg = "scrum in 3 minutes";

    if ($data && $witem && ($witem->{type} eq "CHANNEL"))
    {
      #GOTCHA: I have to call server->print to notify myself. I don't get
      #notified when the "MSG" command is executed.
      $server->print($witem->{name}, $msg, MSGLEVEL_HILIGHT);
      #$witem->command("notify scrum $msg");
      $witem->command("MSG ".$witem->{name}." ${report_order}: $msg");
      $witem->command("timer add scrum_timer 180 1 say  ${report_order}: scrum now");
    }
    else
    {
      Irssi::print("scrum: Nick not given, and no active channel/query in window");
    }
}

sub cmd_foo {
    my ($data, $server, $witem) = @_;
    print "windows: ". repr(Irssi::windows());
}

Irssi::command_bind('colorhelp1', 'cmd_help1');
Irssi::command_bind('colorhelp2', 'cmd_help2');

Irssi::command_bind('scrum', 'cmd_scrum');

Irssi::command_bind('foo', 'cmd_foo');
