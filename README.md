SLD - Spotify link decoder for Irssi
====================================


Looks out for spotify-links and resolves what song or album it is pointing to.

Example message before: [12:23] < NickSteel> Hey check this song out http://open.spotify.com/track/6x1hipqIkn6pyIP4i6vWGW it's awesome!
Example message after:  [12:23] < NickSteel> Hey check this song out Maserati - Monoliths [http://open.spotify.com/track/6x1hipqIkn6pyIP4i6vWGW] it's awesome!

Song/album name is bolded to make it stand out in the message.


There's also a command for resolving URI:s, result is printed to current window

Usage /sld <line with spotify URI>
Example /sld http://open.spotify.com/track/6x1hipqIkn6pyIP4i6vWGW
