#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use AnyEvent;
use AnyEvent::WebSocket::Server;
use File::Basename ('basename');
use MIME::Base64;
use Plack::Builder;
use Plack::App::WebSocket;
use Sys::Virt;
use VirtDancer;

my $wsserver = AnyEvent::WebSocket::Server->new(
    handshake => sub {
        my ($req, $res) = @_;
        $res->subprotocol('binary');
        return $res;
    },
);

builder {
    mount '/vnc' => builder {
        enable "Auth::Basic", authenticator => \&VirtDancer::authenticate, realm => 'Please login';
        Plack::App::WebSocket->new(
            websocket_server => $wsserver,
            on_error         => sub {
                my ($env) = @_;
                return [500,
                        ["Content-Type" => "text/plain"],
                        ["Error: " . $env->{"plack.app.websocket.error"}]];
            },
            on_establish     => sub {
                my $conn = shift;
                my $env  = shift;

                my ($auth_method, $auth_string) = split(' ', $env->{HTTP_AUTHORIZATION});
                my ($username)                  = split(':', decode_base64($auth_string));

                my $uuid   = basename($env->{REQUEST_URI});
                my $domain = VirtDancer::VMM->get_domain_by_uuid($uuid);

                unless(VirtDancer::check_vm_access_by_name($username, $domain->get_name)) {
                    die $username;
                    $conn->close();
                    return;
                }

                my $fd     = $domain->open_graphics_fd(0, 0);
                open(my $fh, "+<&=$fd");

                my $handle = AnyEvent::Handle->new(
                    fh       => $fh,
                    on_read  => sub {
                        my ($self) = @_;
                        my $strong_connection = $conn;

                        my $buffer = $self->rbuf;

                        while($buffer) {
                            my $message = AnyEvent::WebSocket::Message->new(
                                body   => substr($buffer, 0, 65535, ''),
                                opcode => 2,
                            );

                            $conn->send($message);
                            $self->rbuf() = $buffer;
                        }
                    },
                    on_error => sub {
                    },
                );

                $conn->on(
                    message => sub {
                        my ($self, $msg) = @_;
                        my $strong_handle = $handle;
                        $handle->push_write($msg);
                    },
                    finish => sub {
                    }
                );
            }
        )->to_app;
    };
    mount '/'    => VirtDancer->to_app;
};
