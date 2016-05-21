package VirtDancer;
use AnyEvent;
use AnyEvent::Socket;
use List::Util qw(any);
use Dancer2;
use Dancer2::Plugin::Auth::HTTP::Basic::DWIW;
use IO::Handle;
use Sys::Statistics::Linux;
use Sys::Virt;
use Time::HiRes qw(usleep);

set serializer => 'JSON';

our $VERSION = '0.2';

sub VMM {
    Sys::Virt->new(uri => config->{libvirt_uri});
}

sub authenticate {
    my ($user, $pass) = @_;

    my $userconfig = config->{users};

    if(!exists($userconfig->{$user})) {
        return 0;
    }

    my $hash = $userconfig->{$user}->{password};

    return (crypt($pass, $hash) eq $hash);
}

sub check_vm_access_by_name {
    my ($user, $vm_name) = @_;

    if(!exists(config->{users}->{$user})) {
        return 0;
    }

    my $filters = config->{users}->{$user}->{filters};

    if(any { $_ eq $vm_name } @{$filters->{exact}}) {
        return 1;
    }

    if(any { $vm_name =~ m/^\Q$_/ } @{$filters->{prefix}}) {
        return 1;
    }

    if(any { $vm_name =~ m/\Q$_$/ } @{$filters->{suffix}}) {
        return 1;
    }

    return 0;
}

http_basic_auth_set_check_handler sub {
    my ($user, $pass) = @_;
    authenticate($user, $pass);
};

get '/' => sub {
    redirect '/index.html';
};

get '/stats/cpu' => sub {
    my $lxs = Sys::Statistics::Linux->new( cpustats => 1 );
    usleep(250000);
    my $stat = $lxs->get;
    my $cpu  = $stat->cpustats->{cpu};

    return {
        usr => $cpu->{user},
        sys => $cpu->{system},
    };
};

get '/stats/mem' => sub {
};

get '/vm' => http_basic_auth required => sub {
    my ($user)  = http_basic_auth_login;
    my @domains = VMM->list_all_domains();
  
    return [
        map {
            check_vm_access_by_name($user, $_->get_name) ?
                {
                    uuid   => $_->get_uuid_string,
                    name   => $_->get_name,
                    active => \$_->is_active,
                }
            : ()
        } @domains,
    ];
};

get '/vm/:uuid' => http_basic_auth required => sub {
    my ($user) = http_basic_auth_login;
    my $domain = VMM->get_domain_by_uuid(params->{uuid});

    unless(check_vm_access_by_name($user, $domain->get_name)) {
        send_error("Access denied", 403);
    }

    return {
        id         => $domain->get_id,
        uuid       => $domain->get_uuid_string,
        name       => $domain->get_name,
        active     => \$domain->is_active,
        persistent => \$domain->is_persistent,
        updated    => \$domain->is_updated,
        os         => $domain->get_os_type,
        info       => $domain->get_info,
        autostart  => \$domain->get_autostart,
    };
};

post '/vm/:uuid/action' => http_basic_auth required => sub {
    my $domain = VMM->get_domain_by_uuid(params->{uuid});

      params->{action} eq 'shutdown' ? $domain->shutdown
    : params->{action} eq 'destroy'  ? $domain->destroy
    : params->{action} eq 'pause'    ? $domain->suspend
    : params->{action} eq 'start'    ? ($domain->is_active ? $domain->resume : $domain->create)
    : die('Unknown action "' . params->{action} . '"');

    return { result => 'done' };
};

true;
