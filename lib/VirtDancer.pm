package VirtDancer;
use Dancer2;
use Dancer2::Plugin::Auth::HTTP::Basic::DWIW;
use Sys::Statistics::Linux;
use Sys::Virt;
use Time::HiRes qw(usleep);

set serializer => 'JSON';

our $VERSION = '0.1';

sub VMM {
    Sys::Virt->new(uri => config->{libvirt_uri});
}

http_basic_auth_set_check_handler sub {
    my ($user, $pass) = @_;
    return $user eq config->{admin_user} && $pass eq config->{admin_password};
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

get '/vm' => sub {
    my @domains = VMM->list_all_domains();
  
    return [
        map {
            {
                uuid   => $_->get_uuid_string,
                name   => $_->get_name,
                active => \$_->is_active,
            }
        } @domains,
    ];
};

get '/vm/:uuid' => sub {
    my $domain = VMM->get_domain_by_uuid(params->{uuid});

    return {
        id         => $domain->get_id,
        uuid       => $domain->get_uuid_string,
        name       => $domain->get_name,
        active     => \$domain->is_active,
        persistent => $domain->is_persistent,
        updated    => $domain->is_updated,
        os         => $domain->get_os_type,
        info       => $domain->get_info,
        autostart  => $domain->get_autostart,
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
