use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Text::Ngram::MySQL::FullText',
    AUTHOR              => 'Toshimasa Ishibashi <iandeth@gmail.com>',
    VERSION_FROM        => 'lib/Text/Ngram/MySQL/FullText.pm',
    ABSTRACT_FROM       => 'lib/Text/Ngram/MySQL/FullText.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'Encode'     => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Text-Ngram-MySQL-FullText-*' },
);
