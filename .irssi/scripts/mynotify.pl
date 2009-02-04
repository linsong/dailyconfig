#!/usr/bin/env perl -w
#
# This is a simple irssi script to send out notifications using
# growlnotify under MacOSX, notify-send under Linux. 
# Currently, it sends notifications when your name is
# highlighted, and when you receive private messages.
#
# This script is modified based on Growl project's script for irssi

use strict;
use vars qw($VERSION %IRSSI $Notes $AppName);

use Irssi;

$VERSION = '0.1';
%IRSSI = (
	authors		=>	'Vincent Wang',
	contact		=>	'linsong.qizi@gmail.com',
	name		=>	'mynotify',
	description	=>	'Sends out notifications for Irssi',
	license		=>	'BSD',
	url			=>	'http://vincent-wang.blogspot.com'
);

sub cmd_help ($$$) {
	Irssi::print('%G>>%n Mynotify can be configured using three settings:');
	Irssi::print('%G>>%n notify_show_privmsg : Notify about private messages.');
	Irssi::print('%G>>%n notify_show_hilight : Notify when your name is hilighted.');
	Irssi::print('%G>>$h notify_show_notify : Notify when someone on your away list joins or leaves.');  
    Irssi::print('%G>>$h notify_notification_tool : Use which notification. growl(for Mac) or notifiy-send(for linux).');
}

$Notes = ["Script message", "Message notification"];
$AppName = "irssi";

sub notify($$$$)
{
    my ($appname, $identifier, $title, $data) = @_;

    # Make the message entity-safe
    $title =~ s#'#''''#g;
    $data =~ s#'#''''#g;

    # now, I hide the details of OS behind netgrowl.py 
    #system("netgrowl.py -q -n '$title' -m '$data'");
    open(TEMP_HANDLER, '|' . "netgrowl.py -q -n '" . $title . "' -m '" . $data . "'");
    close(TEMP_HANDLER);
}

sub sig_message_private ($$$$) {
	return unless Irssi::settings_get_bool('notify_show_privmsg');

	my ($server, $data, $nick, $address) = @_;

	notify($AppName, "Message notification", "$nick", "$data");
}

sub sig_message_invite($$$$) {
	return unless Irssi::settings_get_bool('notify_show_notify');
	my ($server, $channel, $nick, $address) = @_;

    notify($AppName, "Invitation", "$nick", "$address");
}

sub sig_print_text ($$$) {
	return unless Irssi::settings_get_bool('notify_show_hilight');

	my ($dest, $text, $stripped) = @_;

	if ($dest->{level} & MSGLEVEL_HILIGHT) {
		notify($AppName, "Message notification", $dest->{target}, $stripped);
	}
}

sub sig_notify_joined ($$$$$$) {
	return unless Irssi::settings_get_bool('notify_show_notify');
	my ($server, $nick, $user, $host, $realname, $away) = @_;
	
	notify($AppName, "Message notification", $realname || $nick,
		"<$nick!$user\@$host>\nHas joined $server->{chatnet}");
}

sub sig_notify_left ($$$$$$) {
	return unless Irssi::settings_get_bool('notify_show_notify');
	my ($server, $nick, $user, $host, $realname, $away) = @_;
	
	notify($AppName, "Message notification", $realname || $nick,
		"<$nick!$user\@$host>\nHas left $server->{chatnet}");	
}

sub sig_dcc_request_notify {
    my ($dcc, $sendaddr) = @_;
    my $server = $dcc->{server};

    return if (!$dcc);
    notify($AppName, $server, "DCC ".$dcc->{type}." request", $dcc->{nick});
}


Irssi::command_bind('mynotify', 'cmd_help');

Irssi::signal_add_last('message private', \&sig_message_private);
Irssi::signal_add_last('message invite', \&sig_message_invite);
Irssi::signal_add_last('print text', \&sig_print_text);
Irssi::signal_add_last('notifylist joined', \&sig_notify_joined);
Irssi::signal_add_last('notifylist left', \&sig_notify_left);
Irssi::signal_add_last('dcc request', \&sig_dcc_request_notify);

Irssi::settings_add_bool($IRSSI{'name'}, 'notify_show_privmsg', 1);
Irssi::settings_add_bool($IRSSI{'name'}, 'notify_show_hilight', 1);
Irssi::settings_add_bool($IRSSI{'name'}, 'notify_show_notify', 1);
Irssi::settings_add_str( $IRSSI{'name'}, 'notify_notification_tool', 'growl');

Irssi::print('%G>>%n '.$IRSSI{name}.' '.$VERSION.' loaded (/mynotify for help)');
