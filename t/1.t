
use Test::More tests => 6;

$| = 1;

BEGIN { use_ok('Calendar::Generate::HTML') };

my $a = new Calendar::Generate::HTML;

ok( my $stuff = $a->generate( '2005','04','24' ), "generate" );

print( "$stuff\n" );

ok( $a->row_end(), "row_end" );

print( $a->row_end() . "\n" );

use_ok( 'Calendar::Generate::Text' );

my $text;
ok( $text = new Calendar::Generate::Text, "new text" );
ok( $text->generate( '2005','12','01' ), "generate text" );
