#!perl -T
use strict;
use Test::More tests => 54;
use Encode qw/decode/;
use Text::Ngram::MySQL::FullText;

### _make_ngram_fulltext() + bi-gram
{
	my $p = Text::Ngram::MySQL::FullText->new;

	is($p->_make_ngram_fulltext(''), '');

	my $str = decode 'utf8', 'あさひがでた';
	is($p->_make_ngram_fulltext($str), 'あさ さひ ひが がで でた た');

	$str = decode 'utf8', 'あ';
	is($p->_make_ngram_fulltext($str), 'あ');

	$str = decode 'utf8', 'あい';
	is($p->_make_ngram_fulltext($str), 'あい い');

	$str = decode 'utf8', 'あいう';
	is($p->_make_ngram_fulltext($str), 'あい いう う');
}

### _make_ngram_fulltext() + tri-gram
{
	my $p = Text::Ngram::MySQL::FullText->new(
		window_size => 3 );

	is($p->_make_ngram_fulltext(''), '');

	my $str = decode 'utf8', 'あ';
	is($p->_make_ngram_fulltext($str), 'あ');

	$str = decode 'utf8', 'あい';
	is($p->_make_ngram_fulltext($str), 'あい い');

	$str = decode 'utf8', 'あいう';
	is($p->_make_ngram_fulltext($str), 'あいう いう う');

	$str = decode 'utf8', 'あいうえ';
	is($p->_make_ngram_fulltext($str), 'あいう いうえ うえ え');

	$str = decode 'utf8', 'あさひがでた';
	is($p->_make_ngram_fulltext($str), 'あさひ さひが ひがで がでた でた た');
}

### to_fulltext() + bi-gram
{
	my $p = Text::Ngram::MySQL::FullText->new;

	my $str = decode 'utf8', 'あさひ 焼肉屋';
	is($p->to_fulltext($str), 'あさ さひ ひ 焼肉 肉屋 屋');

	$str = decode 'utf8', 'さひ 焼肉屋';
	is($p->to_fulltext($str), 'さひ ひ 焼肉 肉屋 屋');

	$str = decode 'utf8', 'ひ 焼肉屋';
	is($p->to_fulltext($str), 'ひ 焼肉 肉屋 屋');

	$str = decode 'utf8', 'ひ　 焼　　肉屋';
	is($p->to_fulltext($str), 'ひ 焼 肉屋 屋');

	$str = decode 'utf8', '家）　八重洲店';
	is($p->to_fulltext($str), '家） ） 八重 重洲 洲店 店');
}

### to_fulltext() + tri-gram
{
	my $p = Text::Ngram::MySQL::FullText->new(
		window_size => 3 );

	my $str = decode 'utf8', '家　八重';
	is($p->to_fulltext($str), '家 八重 重');

	$str = decode 'utf8', '家）　八重洲店';
	is($p->to_fulltext($str), '家） ） 八重洲 重洲店 洲店 店');

	$str = decode 'utf8', 'あさひが 焼肉屋';
	is($p->to_fulltext($str), 'あさひ さひが ひが が 焼肉屋 肉屋 屋');
}

### to_query() + bi-gram
{
	my $p = Text::Ngram::MySQL::FullText->new;

	my $str = decode 'utf8', 'あさひ 焼肉屋';
	is($p->to_query($str), '+あさ +さひ +焼肉 +肉屋');

	$str = decode 'utf8', 'さひ 焼肉屋';
	is($p->to_query($str), '+さひ +焼肉 +肉屋');

	$str = decode 'utf8', 'ひ 焼肉屋';
	is($p->to_query($str), '+ひ* +焼肉 +肉屋');

	$str = decode 'utf8', 'ひ　 焼　　肉屋';
	is($p->to_query($str), '+ひ* +焼* +肉屋');

	$str = decode 'utf8', '家）　八重洲店';
	is($p->to_query($str), '+家） +八重 +重洲 +洲店');
}

### to_query() + tri-gram
{
	my $p = Text::Ngram::MySQL::FullText->new(
		window_size => 3 );

	my $str = decode 'utf8', '家　八重';
	is($p->to_query($str), '+家* +八重*');

	$str = decode 'utf8', '家）　八重洲店';
	is($p->to_query($str), '+家）* +八重洲 +重洲店');

	$str = decode 'utf8', 'あさひが 焼肉屋';
	is($p->to_query($str), '+あさひ +さひが +焼肉屋');
}

### pre/post white spaces
{
	my $p = Text::Ngram::MySQL::FullText->new;
	is($p->to_fulltext(' T'),  'T');
	is($p->to_fulltext(' T '), 'T');
	is($p->to_fulltext('T '),  'T');
	is($p->to_fulltext('  T'),  'T');
	is($p->to_query(' T'), '+T*');
	is($p->to_query(' T '), '+T*');
	is($p->to_query('T '), '+T*');
	is($p->to_query('  T'), '+T*');
}

### to_match_sql() + mysql escape string
{
	my $p = Text::Ngram::MySQL::FullText->new(
		column_name => 'hoge' );

	my $str = decode 'utf8', '焼肉';
	is($p->to_query($str), '+焼肉');

	$str = decode 'utf8', q{素材' '焼肉''にく};
	is($p->to_query($str), q{+素材 +材\\' +\\'焼 +焼肉 +肉\\' +\\'\\' +\\'に +にく});

	$str = decode 'utf8', q{素材'};
	is($p->to_match_sql($str), q{MATCH(hoge) AGAINST('+素材 +材\\'' IN BOOLEAN MODE)});

	$str = decode 'utf8', q{'};
	is($p->to_match_sql($str), q{MATCH(hoge) AGAINST('+\\'*' IN BOOLEAN MODE)});

	$str = decode 'utf8', q{A'};
	is($p->to_match_sql($str), q{MATCH(hoge) AGAINST('+A\\'' IN BOOLEAN MODE)});

	$str = decode 'utf8', q{'A};
	is($p->to_match_sql($str), q{MATCH(hoge) AGAINST('+\\'A' IN BOOLEAN MODE)});

	$str = decode 'utf8', q{A'A};
	is($p->to_match_sql($str), q{MATCH(hoge) AGAINST('+A\\' +\\'A' IN BOOLEAN MODE)});
}

### to_match_sql() + bind mode
{
	my $p = Text::Ngram::MySQL::FullText->new(
            column_name => 'hoge' );
	my $str = decode 'utf8', 'あさひ';
	my($sql,$bind) = $p->to_match_sql($str,1);
        is $sql, q{MATCH(hoge) AGAINST(? IN BOOLEAN MODE)};
        is $bind, '+あさ +さひ';
}
{
        my $p = Text::Ngram::MySQL::FullText->new(
            column_name => 'hoge',
            return_bind => 1,
        );
	my $str = decode 'utf8', 'あさひ';
	my($sql,$bind) = $p->to_match_sql($str);
        is $sql, q{MATCH(hoge) AGAINST(? IN BOOLEAN MODE)};
        is $bind, '+あさ +さひ';
}
### to_match_sql() + english 
{
	my $p = Text::Ngram::MySQL::FullText->new(
            column_name => 'hoge' );
	my $str = decode 'utf8', 'あいう pizza';
	my($sql,$bind) = $p->to_match_sql($str,1);
        is $sql, q{MATCH(hoge) AGAINST(? IN BOOLEAN MODE)};
        is $bind, '+あい +いう +pizza*';

	$str = decode 'utf8', 'あいう pizza';
	($sql,$bind) = $p->to_match_sql($str,1);
        is $sql, q{MATCH(hoge) AGAINST(? IN BOOLEAN MODE)};
        is $bind, '+あい +いう +pizza*';

	$str = decode 'utf8', 'あい pizza-party かきく';
	($sql,$bind) = $p->to_match_sql($str,1);
        is $sql, q{MATCH(hoge) AGAINST(? IN BOOLEAN MODE)};
        is $bind, '+あい +pizza* +party* +かき +きく';

	$str = decode 'utf8', 'あ h';
	($sql,$bind) = $p->to_match_sql($str,1);
        is $sql, q{MATCH(hoge) AGAINST(? IN BOOLEAN MODE)};
        is $bind, '+あ* +h*';
}
