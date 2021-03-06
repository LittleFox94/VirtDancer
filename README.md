# VirtDancer
Manage libvirt-based virtual machines in your webbrowser or using the integrated REST-API.

Webinterface using the REST-API implemented with AngularJS and Bootstrap included.

## GUI

There is a new UI in work in a separate project on github and my gitlab:
* https://github.com/LittleFox94/VirtDancer-GUI
* https://praios.lf-net.org/littlefox/virtdancer-ui

## Installation

* Download VirtDancer (don't forget the submodule for noVNC!)
* edit config.yml, for the password you can use the supplied ```hash_password``` command
* install dependencies from cpan: ```cpan Dancer2 Dancer2::Plugin::Auth::HTTP::Basic::DWIW Sys::Statistics::Linux Plack::App::WebSocket Sys::Virt```
* choose a server: Twiggy or Corona (or any other compatible with Plack::App::WebSocket) and install it with cpan, I'm using Twiggy
* ```twiggy bin/app.psgi``` with any other parameters you want, look here for options: https://metacpan.org/pod/plackup
* default login: admin:admin

## Problems/Caveats

### I can't install Sys::Virt from cpan

Look for a version in your distributions package management.

### No virtual machines are listed

Can VirtDancer access the libvirt-socket?

You shouldn't run VirtDancer as root but as it's own user. That user needs access to libvirts Unix-Socket, i.e. on debian you
have to ```adduser virtdancer libvirt``` (given the user is virtdancer).

### The code is bad and you should feel bad!

Really? It may be true for the client-side stuff (HTML, CSS, JS) as this was the first time I was using AngularJS and Bootstrap. It works, but
may not be the nicest code. Feel free to pull request :)

Perl-code should be ok, please tell me when there is something awkward.

## License

VirtDancer is published under the terms of the GNU General Public License version 2.

VirtDancer uses glyphicons from https://glyphicons.com/ via Bootstrap.

VirtDancer uses AngularJS 1, Bootstrap 3 and jQuery 2.
