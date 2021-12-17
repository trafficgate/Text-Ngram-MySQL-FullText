#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Text::Ngram::MySQL::FullText' );
}

diag( "Testing Text::Ngram::MySQL::FullText $Text::Ngram::MySQL::FullText::VERSION, Perl $], $^X" );
