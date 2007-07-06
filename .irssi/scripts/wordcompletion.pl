#!/usr/bin/perl
use Irssi;
use DBI;
use strict;
use vars qw($VERSION %IRSSI);
$VERSION = "0.2";
%IRSSI = (
    authors     => "Jesper Lindh, Christopher Schmidt",
    contact     => "rakblad\@midgard.liu.se,crschmidt\@crschmidt.net",
    name        => "wordcompletion",
    description => "Adds words from IRC to your tab-completion list",
    license     => "Public Domain",
    url         => "http://crschmidt.net/odds/",
    changed     => "2005-08-27"
);

Irssi::settings_add_str('misc', $IRSSI{'name'} . '_user', "user");
Irssi::settings_add_str('misc', $IRSSI{'name'} . '_pass', "pass");
Irssi::settings_add_str('misc', $IRSSI{'name'} . '_dsn', "DBI:mysql:dbtable:dbhost");
Irssi::settings_add_str('misc', $IRSSI{'name'} . '_types', 
                        "message own_public, message own_private, message private, message public");

my ($dbh, $sth);
my (@ary);
my $query;
my $connect = 0;

sub wordsearch
{
	my $sw = shift;
	my @retar;
	my $i = 0;
	$query = qq{ select word from words where word like '$sw%' order by prio desc };
	if ($connect) {
        $sth = $dbh->prepare ( $query );
	    $sth->execute();
	    while (@ary = $sth->fetchrow_array ())
	    {
            	$retar[$i++] = join ("", @ary), "\n";
	    }
	    $sth->finish();
	}
    return @retar;
};
sub wordfind
{
	my $sw = shift;
	my $ret = "";
	$query = qq{ select word from words where word = '$sw' };
    if ($connect) {
        $sth = $dbh->prepare ( $query );
        $sth->execute();
        @ary = $sth->fetchrow_array;
        $ret = join ("", @ary), "\n";
        $sth->finish();
    }
	return $ret;
};

sub wordupdate
{
	my $sw = shift;
	$query = qq { update words set prio = prio + 1 where word = '$sw' };
    if ($connect) {
        $sth = $dbh->prepare ( $query );
        $sth->execute();
        $sth->finish();
    }
};
sub delword
{
	my $sw = shift;
	$query = qq { delete from words where word = '$sw' };
    if ($connect) {
        $sth = $dbh->prepare ( $query );
        $sth->execute();
        $sth->finish();
        print "Deleted $sw.";
    } else {
        print "Wordcompletion is off. Can not delete while wordcompletion is off.";
    }
};
sub addword
{
	my $sw = shift;
	$query = qq { insert into words values ('$sw', 1) };
    if ($connect) {
        $sth = $dbh->prepare ( $query );
        $sth->execute();
        $sth->finish();
    }
};
sub word_complete
{
	my ($complist, $window, $word, $linestart, $want_space) = @_;
        $word =~ s/([^a-zA-Z0-9åäöÅÄÖ])//g;
	@$complist = wordsearch($word);	
};
sub word_message
{
        my ($server, $message) = @_;
        foreach my $word (split(' ', $message))
        {
		$word =~ s/([^a-zA-Z0-9åäöÅÄÖ])//g;
		if (length($word) >= 4)
		{
			my $fword = wordfind($word);
			if ($fword)
			{
				wordupdate($word);
			}
			else
			{
				addword($word);
			};
		};
        };
};
sub cmd_sql_disconnect
{
	$dbh->disconnect();
	print "Disconnected from sql-server";
	$connect = 0;
};
sub cmd_sql_connect
{
	if ($connect == 0)
	{
		print "Connecting to sql-server";
		$dbh = DBI->connect (Irssi::settings_get_str($IRSSI{'name'} . '_dsn'),
                             Irssi::settings_get_str($IRSSI{'name'} . '_user'),
                             Irssi::settings_get_str($IRSSI{'name'} . '_pass'),
                             { RaiseError => 1 });
        foreach my $cword (split(', ', Irssi::settings_get_str($IRSSI{'name'} . '_types')))
        {
                Irssi::signal_add($cword, "word_message");
        };
	    $connect = 1;
    } else {
		print "Already connected";
	};
};
sub start {
    if (Irssi::settings_get_str($IRSSI{'name'} . "_dsn") ne "DBI:mysql:dbname:dbhost" and
        Irssi::settings_get_str($IRSSI{'name'} . "_user") ne "user" and
        Irssi::settings_get_str($IRSSI{'name'} . "_pass") ne "pass") {
            cmd_sql_connect();
            print "Wordcompletion loaded.";
    } else {
        print "Wordcompletion loaded. For help, /wordcompletion help.";
    }
}
sub help {		
print "To use wordcompletion, set wordcompletion_user, wordcompletion_pass, and wordcompletion_dsn. 
Additionally, you can edit the message types with wordcompletion_type.

  wordcompletion_user: Username for MySQL (or other database) user
  wordcompletion_pass: Password for MySQL (or other database) user
  wordcompletion_dsn: Perl DBI DSN for wordcompletion. Default is DBI:mysql:dbtable:dbhost -- however, you may be able to use any database DBI supports if you replace this. Example: DBI:mysql:irssi:localhost.
  wordcompletion_type: List of message levels to watch. Do not touch this unless you know what you are doing.

Once you have set these variables, type /wordcompletion on. To turn it off again, type /wordcompletion off.

To remove a word from the database, type /wordcompletion delete <wordhere> ";
}
sub change_state {
    my ($state, $word) = split(" ", shift);
    
    if ($state eq "on") {
        cmd_sql_connect();
    } elsif ($state eq "off") {
        cmd_sql_disconnect();
    } elsif ($state eq "help") {
        help();
    } elsif ($state eq "delete") {
        delword($word);
    }
}
Irssi::signal_add_last('complete word', 'word_complete');
Irssi::command_bind("wordcompletion", "change_state");
start();
