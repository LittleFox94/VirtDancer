# VirtDancer
Manage libvirt-based virtual machines in your webbrowser or using the integrated REST-API.

Webinterface using the REST-API implemented with AngularJS and Bootstrap included.

Demo at https://rahja.lf-net.org/index.html

## Installation

* Download VirtDancer
* edit config.yml
* install dependencies from cpan: ```cpan Dancer2 Dancer2::Plugin::Auth::HTTP::Basic::DWIW Sys::Statistics::Linux Sys::Virt```
* ```plackup bin/app.psgi``` in any way you want, look here for options: https://metacpan.org/pod/plackup

## Problems/Caveats

### I can't install Sys::Virt from cpan

Look for a version in your distributions package management.

### No virtual machines are listed

Can VirtDancer access the libvirt-socket?

You shouldn't run VirtDancer as root but as it's own user. That user needs access to libvirts Unix-Socket, i.e. on debian you
have to ```adduser virtdancer libvirt``` (given the user is virtdancer).

### Anonymous users can see anything

Yes, all people can see everything. But only users with the admin-credentials can do actions (such as starting or stopping virtual machines).

I've written this software for my server where this was wanted, I'm open to pull-requests, but given the architecture of
Dancer2::Plugin::Auth::HTTP::Basic::DWIW, there may not be another way yet. I'm open to pull requests there, too ;)

### The code is bad and you should feel bad!

Really? It may be true for the client-side stuff (HTML, CSS, JS) as this was the first time I was using AngularJS and Bootstrap. It works, but
may not be the nicest code. Feel free to pull request :)

Perl-code should be ok, please tell me when there is something awkward.

## License

VirtDancer is published under the terms of the GNU General Public License version 2.

VirtDancer uses glyphicons from https://glyphicons.com/ via Bootstrap.

VirtDancer uses AngularJS 1, Bootstrap 3 and jQuery 2.
