
package Calendar::Generate;
require 5.002;

use Date::Calc qw(Day_of_Week Days_in_Month Month_to_Text Day_of_Week_to_Text);

#
# Origional (Date::Calendar) version Copyright (c) 1997-1998 Matthew Darwin.
# All rights reserved. This program is free software; you can redistribute it
# and/or modify it under the same terms as Perl itself.
#

$VERSION='0.62';

sub new {
	my $class = shift;

	bless {
		   _buffer => '',
		  }, $class;
}

sub rules {
	my( $self, $params ) = @_;

    foreach my $key ( keys %{ $params } ) {
        $self->{$key} = $params->{$key};
    }
	$self->{_ready} = 1;
	return 1;
}

sub day_data {
	my( $self, $args ) = @_;

	return undef unless exists( $args->{year} );
	$self->{data}->{$args->{year}}->{$args->{month}}->{$args->{$day}} = $args->{text};
	return $self->{data};
}

sub reset {
	$_[0]->{_buffer} = '';
}

sub calendar {
	return $_[0]->{_buffer};
}

sub month_current {
    my( $year, $month, $day ) = ( localtime( time() ) )[5,4,3];

    $month++;
    $year += 1900;
    return $_[0]->generate( $year, $month, $day );
}

sub generate {
    my ($self, $yy, $mm, $dd) = @_;

	return undef unless $dd;

	# Make sure that there is at least some formatting data.
	# we don't want to throw up a ton of undefined errors.
	$self->rules_cal() unless exists( $self->{_ready} );

    my ($weekday, $days, $day);
	$weekday = Day_of_Week ($yy, $mm, 1);
	$weekday = 0 if $weekday == 7;
    $days = Days_in_Month ($yy, $mm);
    $day = 1;

	$self->{_buffer} .= $self->{month_header};

    $self->month_title( Month_to_Text ($mm), $yy, undef );
    $self->dows();

	$self->{_buffer} .= $self->{row_start} if $weekday != 0;

    $self->spacer( $weekday );
    while ($day < ($days + 1)) {
		$self->{_buffer} .= $self->{row_start} if $weekday == 0;
        if ( $day == $dd ) {
            $self->day( $yy, $mm, $day, 1 );
        } else {
            $self->day( $yy, $mm, $day );
        }
        $day++;
		$self->{_buffer} .= $self->{row_end} if $weekday == 6;
        $weekday = ($weekday + 1) % 7;
    }
    if ($weekday != 0) {
        $self->spacer( 7 - $weekday );
		$self->{_buffer} .= $self->{row_end};
    }
	$self->{_buffer} .= $self->{month_footer};
	return $self->{_buffer};
}

sub dows {
	my $self = shift;
	my( $i, $name );

	$self->{_buffer} .= $self->{row_start};
    for $i (7, 1, 2, 3, 4, 5, 6)  {
        $name = Day_of_Week_to_Text ($i);
		$self->{_buffer} .= $self->{dow_start};
		$self->{_buffer} .= substr( $name, 0, $self->{dow_length} );
		$self->{_buffer} .= $self->{dow_end};
    }
	$self->{_buffer} .= $self->{row_end};
	return $self->{_buffer};
}

sub day {
	my( $self, $year, $month, $day, $highlight ) = @_;


	if ( $highlight ) {
		$self->{_buffer} .= $self->{highlight_start};
	} else {
		$self->{_buffer} .= $self->{digit_start};
	}

    my $data = $self->{data}->{$year}->{$month}->{$day};
	if ( (defined( $data ) ) && $self->{data_use} == 2 ) {
        $data = $self->{data_null};
    }

    if (($self->{data_use} == 1) || ((defined $data) && ($self->{data_use} == 2))) {
        if ($self->{data_place} == 1) {
			$self->{_buffer} .= sprintf( "%2d", $day );
        }
        if (($self->{data_use} == 2) || (defined $data)) {
			$self->{_buffer} .= $self->{data_start};
        }
        if (defined $data) {
			$self->{_buffer} .= $data;
        } else {
            if ($self->{data_use} == 2) {
				$self->{_buffer} .= $self->{data_null};
            }
        }
        if (($self->{data_use} == 2) || (defined $data)) {
			$self->{_buffer} .= $self->{data_end};
        }
        if ($self->{data_place} == 0) {
			$self->{_buffer} .= sprintf( "%2d", $day );
        }
    } else {
		$self->{_buffer} .= sprintf( "%2d", $day );
    }

	if ( $highlight ) {
		$self->{_buffer} .= $self->{highlight_end};
	} else {
		$self->{_buffer} .= $self->{digit_end};
	}
	return $self->{_buffer};
}

sub spacer {
	my( $self, $number ) = @_;
	my $i;

	for ($i = 0; $i < $number; $i++) {
		$self->{_buffer} .= $self->{space_start};
		$self->{_buffer} .= $self->{space_char};
		$self->{_buffer} .= $self->{space_end};
    }
	return $self->{_buffer};
}

sub month_title {
    my( $self, $month, $year ) = @_;
    my( $string, $length, $space_l, $space_r );

    if (defined ($self->{title_text})) {
        $string = "$month $year " . $self->{title_text};
    } else {
        $string = "$month $year";
    }

    if ( exists( $self->{title_center} ) ) {
        $length = length ($self->{row_start})
		        + length ($self->{row_end})
                + ( 7 * length ($self->{dow_start}))
                + ( 7 * length ($self->{dow_end}))
                + ( 7 * $self->{dow_length})
                - length ($self->{title_start})
				- length ($self->{title_end});
        $space_l = ($length / 2) - (int (length ($string)) / 2);
        $space_r = $length - $space_l - (length ($string));
        ((int (length ($string) / 2 ) * 2) == length ($string)) || $space_r++;
		$self->{_buffer} .= $self->{title_start};
		$self->{_buffer} .= " " x $space_l;
		$self->{_buffer} .= $string;
		$self->{_buffer} .= " " x $space_r;
		$self->{_buffer} .= $self->{title_end}
    } else {
		$self->{_buffer} .= $self->{title_start};
		$self->{_buffer} .= $string;
		$self->{_buffer} .= $self->{title_end};
    }

    return $self->{_buffer};
}

sub rules_null {
	my $self = @_;

    $self->rules( {
				 month_header => '',
				 title_start => '',
				 title_end => '',
				 title_center => 0,
				 row_start => '',
				 row_end => '',
				 space_start => '',
				 space_char => '',
				 space_end => '',
				 highlight_start => '',
				 highlight_end => '',
				 digit_start => '',
				 digit_end => '',
				 dow_start => '',
				 dow_end => '',
				 dow_length => 99,
				 month_footer => '',
				 data_use => 0,
				 data_start => '',
				 data_end => '',	
				 data_null => '',
				 data_place => 0
				} );
}

sub rules_cal {
	my $self = shift;

    $self->rules( {
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
				 dow_length => 2,
				 month_footer => "\n",
				 data_use => 0,
				 data_start => '',
				 data_end => '',	
				 data_null => '',
				 data_place => 0
				} );
}

#
# An example layout (used for testing)
#

sub rules_ex1 {
    $_[0]->rules( {
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
				} );
    return 1;
}

sub rules_html {
	$_[0]->rules( {
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
				 data_use => 0,
				 data_start => '',
				 data_end => '',	
				 data_null => '',
				 data_place => 1
				} );
	return 1;
}

__END__

=head1 NAME

Calendar::Generate - Rule based calendar generation.

=head1 SYNOPSIS

This is alpha code.  API is subject to (and will) change.

 # The easy way.

 use Calendar::Generate;

 my $calendar = new Calendar::Generate;
 print $calendar->generate( 2004, 12, 25 );

 # The detailed way.

 use Calendar::Generate;
 
 my $calendar = new Calendar::Generate;
 $calendar->rules( 
      -month_header => "<TABLE>\n",
      -title_start => '<TR><TD COLSPAN=7 ALIGN=CENTER>',
      -title_end => "</TD></TR>\n",
      -title_center => 1,
      -title_text => undef,
      -row_start => '<TR> ',
      -row_end => "</TR>\n",
      -space_start => '<TD>&nbsp;',
      -space_char => '',
      -space_end => '&nbsp;&nbsp;&nbsp;</TD>',
      -highlight_start => '<TD>&nbsp;<B>',
      -highlight_end => '</B>&nbsp;</TD>',
      -digit_start => '<TD>&nbsp;',
      -digit_end => '&nbsp;</TD>',
      -dow_start => '<TH WIDTH=14%> ',
      -dow_end => '&nbsp;</TH>',
      -dow_length => 3,
      -month_footer => "</TABLE>\n",
      -data_use => 0,
      -data_start => '',
      -data_end => '',	
      -data_null => '',
      -data_place => 1
 );

 print $calendar->generate( 2004, 12, 25 );

=head1 DESCRIPTION

Calendar::Generate creates a calendar formatted based on rules that you provide.

=head2 Creating a new object

 $calendar = new Calendar::Generate;

=head2 Setting rules

 $calendar->rules( { param => value, ... } );

=head1 FORMATTING RULES

=over 4

=item -month_header

Printed before the calendar.

=item -title_start

The left of the month title.

=item -title_end

The right of the month title.

=item -title_center

Define this to center the month title.

=item -row_start

For before every row in the calendar (excluding title).

=item -row_end

For the end of every row in the calendar (excuding title).

=item -space_start

Formatting start for a blank entry.

=item -space_char

Chracter to use for a blank space.

=item -space_end

Formatting for use at the end of a blank entry.

=item -highlight_start

Formatting for the start of a highlighted entry.

=item -highlight_end

... and the end of a highlighted entry.

=item -digit_start

Formatting used before the printing of the day number.

=item -digit_end

... and the end of the day number.

=item -dow_start

Formatting for the start of a day of the week.

=item -dow_end

... are you starting to see a pattern here?

=item -dow_length

The number of letters of the day of the week to print.

=item -month_footer

Printed at the end of the calendar.

=item -data_use

Determines if data associated with each date should be printed (0 = no, 1 = yes/don't print nulls, 2 = yes/print nulls)

=item -data_null

The data to use for a day that has no associated data.

=item -data_start

Formatting for the start of a data item.

=item -data_end

... and the end.

=item -data_place

determines where data item should be placed (0 = before, 1 = after)

=head2 Printing output

 Both of these return the formatted calendar.
 $calendar->generate( 'Year', 'Month', 'Day' );
 $calendar->calendar();

Generate actually builds the calendar so if you plan to use get_calendar() for whatever reason, you need to have first called generate()

=head1 PROVIDED RULESETS

 $calendar->rules_cal();

This is a set of attributes which will make the output look like that
of L<cal(1)>.   It is also currently the default set of attributes.

 $calendar->rules_html();

This is a set of attributes which will make the output print well in
a table compliant web browser.  It also works in the Lynx text browser.

=back

=head1 AUTHOR

This module is based on code origionally written by Matthew Darwin
and the origional version is available at http://www.mdarwin.ca/perl

Currently the maintainer is Clint Moore <cmoore@cpan.org>

=head1 SEE ALSO

L<Date::DateCalc(3)>
L<cal(1)>

=cut
