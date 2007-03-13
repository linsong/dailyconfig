# [#bitlbee] set typing_notice true
# <@root> typing_notice = `true'
# AND
# /statusbar window add typing_notice

use strict;
use Irssi::TextUI;

use vars qw($VERSION %IRSSI $itime_ratio $current_itime);

$VERSION = '0.9';
%IRSSI = (
    authors     => 'Tijmen "timing" Ruizendaal',
    contact     => 'tijmen@fokdat.nl',
    name        => 'bitlbee_typing_notice',
    description => 'adds an item to the status bar wich shows when someone is typing a message on the supported IM-networks',
    license => 'GPLv2',
    url     => 'http://fokdat.nl/~tijmen/software/index.html',
    changed => '05-29-2004',
);
my %typing;
my %tag;

sub event_notice {
  my ($server, $msg, $from, $address) = @_;
  my ($my_nick, $msg) = split(/:/,$msg,2);
  if ($msg eq "* Typing a message *"){
    Irssi::signal_stop();
    $typing{$from} = 1;
    Irssi::timeout_remove($tag{$from});
    $tag{$from} = Irssi::timeout_add(7000, 'empty', $from);
       
    my $window = Irssi::active_win();
    my $channel = $window->get_active_name();
    if ($from eq $channel){
      Irssi::statusbar_items_redraw('typing_notice');
    }
  }
}
sub event_privmsg {
  my ($server, $data, $from, $address) = @_;
  if ($typing{$from} == 1){
    $typing{$from} = 0;
  }
  my $window = Irssi::active_win();
  my $channel = $window->get_active_name();
  
  if ($channel eq $from){ 
    $typing{$channel} = 0;
    Irssi::timeout_remove($tag{$from});
    Irssi::statusbar_items_redraw('typing_notice');
  }
}
sub typing_notice {
  my ($item, $get_size_only) = @_;
  my $window = Irssi::active_win();
  my $channel = $window->get_active_name();
    
  if ($typing{$channel} == 1){
    $item->default_handler($get_size_only, "{sb typing}", 0, 1);
  }else{
    $item->default_handler($get_size_only, "", 0, 1);
    Irssi::timeout_remove($tag{$channel});
  } 
}
sub empty{
  my $from = shift;
  $typing{$from} = 0;
  Irssi::statusbar_items_redraw('typing_notice');
}
sub window_change{
  my $window = Irssi::active_win();
  my $channel = $window->get_active_name();
  Irssi::statusbar_items_redraw('typing_notice');
}

Irssi::signal_add("event notice", "event_notice");
Irssi::signal_add("event privmsg", "event_privmsg");
Irssi::signal_add_last('window changed', 'window_change');
Irssi::statusbar_item_register('typing_notice', undef, 'typing_notice');
Irssi::statusbars_recreate_items();

