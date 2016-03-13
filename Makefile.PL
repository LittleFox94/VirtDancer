use strict;
use warnings;
use ExtUtils::MakeMaker;

# Normalize version strings like 6.30_02 to 6.3002,
# so that we can do numerical comparisons on it.
my $eumm_version = $ExtUtils::MakeMaker::VERSION;
$eumm_version =~ s/_//;

WriteMakefile(
    NAME                => 'VirtDancer',
    AUTHOR              => q{Moritz "LittleFox" Grosch <littlefox@cpan.org>},
    VERSION_FROM        => 'lib/VirtDancer.pm',
    ABSTRACT            => 'Manage libvirt-based virtual machines with only a webbrowser or use the REST-API.',
    ($eumm_version >= 6.3001
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'                               => 0,
        'YAML'                                     => 0,
        'Dancer2'                                  => 0.166001,
        'Dancer2::Plugin::Auth::HTTP::Basic::DWIW' => 0.0301,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'VirtDancer-*' },
);
