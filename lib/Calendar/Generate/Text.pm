package Calendar::Generate::Text;
use base qw( Calendar::Generate );

sub new {
	my $class = shift;
	bless {
		month_header => '-' x 40 . "\n",
		title_start => '-> > > > >',
		title_end => "< < < < <-\n",
		title_center => 1,
		title_text => "(ex)",
		row_start => '-> ',
		row_end => "<-\n",
		space_start => '[',
		space_char => 'XX',
		space_end => '] ',
		highlight_start => '<',
		highlight_end => '> ',
		digit_start => '[',
		digit_end => '] ',
		dow_start => ' ',
		dow_end => ' ',
		dow_length => 3,
		month_footer => '-' x 40 . "\n\n",
		data_use => 1,
		data_start => '<*',
		data_end => '*>',	
		data_null => 'X',
		data_place => 1
	}, $class;
}

1;

__END__
