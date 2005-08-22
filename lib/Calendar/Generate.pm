
package Calendar::Generate;
use base 'Class::Accessor';

Calendar::Generate->mk_accessors( qw(
	buffer
	month_header month_title month_footer
	row_end row_start
	highlight_start highlight_end
	digit_start digit_end
	title_start title_end title_text title_center
	space_start space_char space_end
	dow_start dow_end dow_length
	data_start data_end data_null data_place
) );

use Date::Calc qw(Day_of_Week Days_in_Month Month_to_Text Day_of_Week_to_Text);
use Carp;

$VERSION='0.7_01';

sub day_data {
	my( $self, $args ) = @_;

	return undef unless exists( $args->{day} );
	$self->{data}->{$args->{day}} = $args->{text};
	return $self->{data};
}

sub month_current {
	my( $year, $month, $day ) = ( localtime( time() ) )[5,4,3];
	$month++;
	$year += 1900;
	return $_[0]->generate( $year, $month, $day );
}

sub generate {
	my( $self, $yy, $mm, $dd ) = @_;

	my ($weekday, $days, $day);
	$weekday = Day_of_Week ($yy, $mm, 1);
	$weekday = 0 if $weekday == 7;
	$days = Days_in_Month ($yy, $mm);
   $day = 1;

	$self->{_buffer} .= $self->month_header();
   $self->month_title( Month_to_Text ($mm), $yy, undef );
   $self->dows();

	$self->{_buffer} .= $self->row_start() if $weekday != 0;

    $self->spacer( $weekday );
    while ($day < ($days + 1)) {
		$self->{_buffer} .= $self->row_start() if $weekday == 0;
        if ( $day == $dd ) {
            $self->day( $yy, $mm, $day, 1 );
        } else {
            $self->day( $yy, $mm, $day );
        }
        $day++;
		$self->{_buffer} .= $self->row_end() if $weekday == 6;
      $weekday = ($weekday + 1) % 7;
    }
    if ($weekday != 0) {
      $self->spacer( 7 - $weekday );
		$self->{_buffer} .= $self->row_end();
    }
	$self->{_buffer} .= $self->{month_footer};
	return $self->{_buffer};
}

sub dows {
	my $self = shift;
	my( $i, $name );

	$self->{_buffer} .= $self->row_start();
    for $i (7, 1, 2, 3, 4, 5, 6)  {
        $name = Day_of_Week_to_Text ($i);
		$self->{_buffer} .= $self->dow_start();
		$self->{_buffer} .= substr( $name, 0, $self->dow_length() );
		$self->{_buffer} .= $self->dow_end();
    }
	$self->{_buffer} .= $self->row_end();
	return $self->{_buffer};
}

sub day {
	my( $self, $year, $month, $day, $highlight ) = @_;

	defined( $highlight ) ?
		$self->{_buffer} .= $self->highlight_start() :
		$self->{_buffer} .= $self->digit_start();

	if ( exists( $self->{data}->{$day} ) ) {

		my $data = $self->{data}->{$day};
	    if ($self->{data_place} == 1) {
			$self->{_buffer} .= sprintf( "%2d", $day );
	    }
		defined( $data ) and $self->{_buffer} .= $self->data_start();

	    if (defined $data) {
			$self->{_buffer} .= $data;
	    } else {
	        if ($self->{data_use} == 2) {
				$self->{_buffer} .= $self->data_null();
	        }
	    }

		defined( $data ) and $self->{_buffer} .= $self->data_end();
		
	    if ($self->{data_place} == 0) {
			$self->{_buffer} .= sprintf( "%2d", $day );
	    }
	} else {
		$self->{_buffer} .= sprintf( "%2d", $day );
	}

	if ( $highlight ) {
		$self->{_buffer} .= $self->highlight_end();
	} else {
		$self->{_buffer} .= $self->digit_end();
	}
	return $self->{_buffer};
}

sub spacer {
	my( $self, $number ) = @_;
	my $i;

	for ($i = 0; $i < $number; $i++) {
		$self->{_buffer} .= $self->space_start();
		$self->{_buffer} .= $self->space_char();
		$self->{_buffer} .= $self->space_end();
    }
	return $self->{_buffer};
}

sub month_title {
    my( $self, $month, $year ) = @_;
    my( $string, $length, $space_l, $space_r );

    if (defined ($self->title_text())) {
        $string = "$month $year " . $self->title_text();
    } else {
        $string = "$month $year";
    }

	if ( $self->title_center() ) {
		$length = length ($self->row_start()) + length ($self->row_end())
			+ ( 7 * length ($self->dow_start()))
         + ( 7 * length ($self->dow_end()))
         + ( 7 * $self->dow_length()) - length ($self->title_start())
			- length ($self->title_end());
		$space_l = ($length / 2) - (int (length ($string)) / 2);
      $space_r = $length - $space_l - (length ($string));
      ((int (length ($string) / 2 ) * 2) == length ($string)) || $space_r++;
		$self->{_buffer} .= $self->title_start();
		$self->{_buffer} .= " " x $space_l;
		$self->{_buffer} .= $string;
		$self->{_buffer} .= " " x $space_r;
		$self->{_buffer} .= $self->title_end()
    } else {
		$self->{_buffer} .= $self->dow_start();
		$self->{_buffer} .= $string;
		$self->{_buffer} .= $self->title_end();
    }
    return $self->{_buffer};
}

1;

__END__

=head1 NAME

Calendar::Generate - Rule based calendar generation.

=head1 SYNOPSIS

This is a development release.  There are gross inefficiencies, stupifyingly bad
loops and structures, and some really poor design decisions.  I'm working to change
that.  This version of Calendar::Generate is a definite departure from the older 
versions in several respects so if you are upgrading, expect your scripts to, at the
very least, not work.

 # The easy way.

 use Calendar::Generate::HTML;

 my $calendar = new Calendar::Generate::HTML;
 $calendar->row_start( '<div id="calendar">' );
 $calendar->row_end( '</div>' );
 ... 
 print $calendar->generate( 2004, 12, 25 );

 # The detailed way.

 # Create your own calendar subclass and override the formatting rules that
 # you wish to be different.

 package MyCalendar;
 use base 'Calendar::Generate::HTML';

 # override the rules that you want to change...
 sub row_start {
	return "<div id='calendar'>";
 }
 sub row_end {
	return "</div>";
 }
 
 # and so on...
 
 1;

 # Create a script to use your fancy-pants new subclass...
 ...
 my $calendar = new MyCalendar;
 print $calendar->generate( 2004, 12, 25 );
 ...

=head1 DESCRIPTION

Calendar::Generate creates a formatted calendar based on rules that you provide.

=head2 Setting rules

 There are essentially two approaches to editing the formatting rules.  You can
 subclass one of the provided formatting modules (ie. Calendar::Generate::HTML) 
 and override the rules that you would like changed, or you can call the methods
 directly from your script which is arguably less elegant.

=head1 METHODS

=item generate( year, month, day );

 Generates the calendar.  Returns a string chock full of calendar-ie goodness.

=over 4

=head1 FORMATTING RULES

 All formatting rules are actually L<Class::Accessor> methods.

=over 4

=item month_header

Printed before the calendar.

=item title_start

The left of the month title.

=item title_end

The right of the month title.

=item title_center

Define this to center the month title.

=item row_start

Before every row in the calendar (excluding title).

=item row_end

The end of every row in the calendar (excuding title).

=item space_start

Formatting start for a blank entry.

=item space_char

Chracter to use for a blank space.

=item space_end

Formatting for use at the end of a blank entry.

=item highlight_start

Formatting for the start of a highlighted entry.

=item highlight_end

... and the end of a highlighted entry.

=item digit_start

Formatting used before the printing of the day number.

=item digit_end

... and the end of the day number.

=item dow_start

Formatting for the start of a day of the week.

=item dow_end

... are you starting to see a pattern here?

=item dow_length

The number of letters of the day of the week to print.

=item month_footer

Printed at the end of the calendar.

=item data_null

Text to insert for days that have no associated data.

=item data_start

Formatting for the start of a data item.

=item data_end

... and the end.

=item data_place

Determines where data item should be placed in relation to the day number.
'0' for before, and '1' for after.

=head2 Printing output

 Both of these return the formatted calendar.
 $calendar->generate( 'Year', 'Month', 'Day' );
 $calendar->calendar();

Generate actually builds the calendar so if you plan to use get_calendar() 
for whatever reason, you need to have first called generate()

=head1 AUTHOR

Clint Moore <cmoore@cpan.org>

=head1 SEE ALSO

L<Date::DateCalc(3)>
L<cal(1)>

=cut
