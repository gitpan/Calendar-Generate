
use Test::More tests => 7;

$| = 1;

BEGIN { use_ok('Calendar::Generate') };

ok( my $ics = new Calendar::Generate, 'new' );
ok( $ics->rules_html, 'html_table' );

ok( $ics->generate( 2004, 12, 25 ), 'generate' );
ok( $ics->calendar(), 'calendar' );

$ics->reset();

ok( $ics->rules( {
				  month_header => '',
				  title_start => '',
				  title_end => "\n",
				  title_center => 1,
				  row_start => '',
				  row_end => "\n",
				  space_start => '',
				  space_char => '  ',
				  space_end => ' ',
				  highlight_start => '',
				  highlight_end => ' ',
				  digit_start => '',
				  digit_end => ' ',
				  dow_start => '',
				  dow_end => ' ',
				  dow_length => 3,
				  month_footer => "\n",
				  data_use => 0,
				  data_start => '',
				  data_end => '',	
				  data_null => '',
				  data_place => 0
				 } ), 'rules' );

ok( $ics->generate( '2004','12','25' ), 'generate' );
