requires "AnyEvent" => 0;
requires "AnyEvent::WebSocket::Server" => 0;
requires "Plack::App::WebSocket" => 0;
requires "Twiggy" => 0;
requires "EV" => 0;
requires "Sys::Statistics::Linux" => 0;
requires "Term::ReadKey" => 0;
requires "Dancer2" => "0.166001";
requires "Dancer2::Plugin::Auth::HTTP::Basic::DWIW" => "0.0301";

# comes from system
#requires "Sys::Virt" => "==3.0.0";

recommends "YAML"             => "0";
recommends "URL::Encode::XS"  => "0";
recommends "CGI::Deurl::XS"   => "0";
recommends "HTTP::Parser::XS" => "0";

on "test" => sub {
    requires "Test::More"            => "0";
    requires "HTTP::Request::Common" => "0";
};
