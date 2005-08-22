
package Calendar::Generate::HTML;
use base qw( Calendar::Generate );

sub new {
	my $class = shift;
	bless {
		month_header => "<TABLE>\n",
		title_start => '<TR><TD COLSPAN=7 ALIGN=CENTER>',
		title_end => "</TD></TR>\n",
		title_text => undef,
		row_start => '<TR> ',
		row_end => "</TR>\n",
		space_start => '<TD>&nbsp;',
		space_char => '',
		space_end => '&nbsp;&nbsp;&nbsp;</TD>',
		highlight_start => '<TD>&nbsp;<B>',
		highlight_end => '</B>&nbsp;</TD>',
		digit_start => '<TD>&nbsp;',
		digit_end => '&nbsp;</TD>',
		dow_start => '<TH WIDTH=14%> ',
		dow_end => '&nbsp;</TH>',
		dow_length => 3,
		month_footer => "</TABLE>\n",
		data_start => '&nbsp;<font color="green">',
		data_end => '</font>',	
		data_null => '',
		data_place => 1,
		title_center => '',
	}, $class;
}

1;

__END__
