# sld.pl
#
# Looks out for spotify and youtube links and resolves what song/album/title it is pointing to.
#
# Example message before: [12:23] < NickSteel> Hey check this song out http://open.spotify.com/track/6x1hipqIkn6pyIP4i6vWGW it's awesome!
# Example message after:  [12:23] < NickSteel> Hey check this song out Maserati - Monoliths (http://open.spotify.com/track/6x1hipqIkn6pyIP4i6vWGW) it's awesome!
#
# Song/album name is bolded to make it stand out in the message.
#
#
# There's also a command for resolving URI:s, result is printed to current window
#
# Usage /sld <line with spotify URI>
# Example /sld http://open.spotify.com/track/6x1hipqIkn6pyIP4i6vWGW
# 
#
# Required libraries: LWP
#
#
# History
#
# 1.1b (2013-04-24)
# - Refined regexp to catch youtube links with additional parameters, example: https://www.youtube.com/watch?v=XUKFLuhwe1w&feature=youtu.be
#
#
# 1.1 (2013-04-24)
# - Added youtube support
# - Changed [] from around the link to () in order to maintain clickability.
# - Changed name to SpotiTube Link Decoder
#


use Irssi;
use Irssi::Irc;
use strict;
use LWP::Simple;
use vars qw($VERSION %IRSSI);

$VERSION = '1.1b';
%IRSSI = (
  authors => 'Laamanni',
  contact => 'Laamanni @ IRCnet',
  name    => 'SpotiTube Link Decoder',
  description => 'Looks out for spotify and youtube links and resolves what song/album/title it is pointing to.',
  changed => '2013-04-24 20:24',
);

sub event_msg {
  my ($server, $data, $nick, $address, $target) = @_;
  $target = $nick if $target eq "";
  $nick = $server->{'nick'} if $address eq "";
  
  my @string_as_array = split(' ', $data );

  my $string;
  my $found = 0;
  my @new_msg;
  for $string (@string_as_array)
  {
    if ( check_for_match($string) ) {
	  $found = 1;
	  $string = "\x{02}" . resolve_link($string) . "\x{02} (" . $string . ")";
    }
    push(@new_msg, $string);
  }
  if ( $found == 1 ) {
    if ( $target eq $nick ) {
	  Irssi::signal_emit("message private", $server, Irssi::parse_special(join(" ", @new_msg)), $nick, $address, $target);
    }
    else {
      Irssi::signal_emit("message public", $server, Irssi::parse_special(join(" ", @new_msg)), $nick, $address, $target);
	}
    Irssi::signal_stop();
  }
}

sub own_msg {

  my ($text) = @_;
  
  my @string_as_array = split(' ', $text );

  my $string;
  my $found;
  for $string (@string_as_array)
  {
    if ( check_for_match($string) ) {
	  $string = "\x{02}" . resolve_link($string) . "\x{02} (" . $string . ")";
	  Irssi::active_win()->print($string);
	  $found = 1;
    }
  }
  if ( $found == 0 ) {
  	Irssi::active_win()->print("No valid spotify/youtube link found!");;
  }
}

sub check_for_match {
  my ($string) = @_;
  #my $reg = '(http://)?open\.spotify\.com/(track|album)/\w{22}'; # only spotify links
  #my $reg = '(http(s)?://)?(open\.spotify\.com/(track|album)/\w{22}|(www\.)?youtube\.com/watch\?v=\w{11})'; # spotify and youtube links
  my $reg = '(http(s)?://)?(open\.spotify\.com/(track|album)/\w{22}|(www\.)?youtube\.com/watch\?v=\w{11}&?.*)'; # spotify and youtube (with other parameters) links
  if ($string =~ m/^$reg$/is) {
	return 1;
  }
  else {
    return 0;
  }
}

sub resolve_link {
  my $link = @_[0];
  my $content;
  $content = get("http://www.mindless.fi/laamanni/irssi-spotify/index.php?url=".$link);
  die "Something went terribly wong!" unless defined $content;

  return $content;
}


Irssi::command_bind("sld", "own_msg");
Irssi::signal_add_first("message private", "event_msg");
Irssi::signal_add_first("message public", "event_msg");
