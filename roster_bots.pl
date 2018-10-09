#!/usr/bin/perl

use Test::More;
use Data::Dumper;
use strict;
use warnings;

## constants
use constant STAT_START => 25;
$Data::Dumper::Sortkeys = 1;

## Global variables for control purposes
my @scores;
my @names;
my $Debug = 0;

sub generate_name {
	## Neede alphanumeric characters
	my @chars = ('a'..'z', 'A'..'Z', 0..9);

	## Generate random name
	my $name = join '', map $chars[rand @chars], 0..7;

	## Check to see if it has happened before, if so, redo
	if (grep { $_ eq $name} @names) {
		print "$name found in names array. Redoing...\n" if $Debug;
		generate_name();
	}

	push @names, $name;
	return $name;
}

sub generate_stats  {
	
	my $stats = {
	speed    => 25,
	strength => 25,
	agility  => 25,
	};

	## randomize each stat within a certain range. 25 + 8 = 33 x 3 = 99 < 100
	foreach my $stat ( keys %$stats) {
		my $modifier = int rand(8);
		$stats->{$stat} += $modifier;
	}

	## grab total of all stats to check for duplicate scores
	my $total = eval join '+', values %$stats;

	## Check to see if it has happened before, if so, redo
	if (grep { $_ == $total} @scores) {
		print "$total found in scores array. Redoing...\n" if $Debug;
		generate_stats();
	}
	
	push @scores, $total;

	return $stats;
}
## Generate function
### Input: Nothing
### Returns: A structure with the league placements

sub generate_league {
	my $league;

	my @standbys;

	## Player creation
	foreach my $itr (1..15) {
		my $name;
		my $stats;

		$name = generate_name();
		$league->{Players}->{$itr}->{name} = $name;

		$stats = generate_stats();
		$league->{Players}->{$itr}->{stats} = $stats;

		## randomly assign starter/substitute status
		my $status = int rand(2);

		if (!$status && scalar @standbys < 5) {
			$league->{Players}->{$itr}->{status} = "Substitute";
			push @standbys, 1;
		} else {
			$league->{Players}->{$itr}->{status} = "Starter";
		}

		## fair payment for all players
		$league->{Players}->{$itr}->{salary} = sprintf("%.2f", 175/15);
	}

	return $league;
}
## test function
sub test_roster_bots {

	## standard test
	is(1, 1, "Sanity test");
	
	my $league = generate_league();

	## player count test
	my $sub_count = 0;
	my $starter_count = 0;
	foreach my $Player (keys %{$league->{Players}}) {
		$sub_count++ if $league->{Players}->{$Player}->{status} eq "Substitute";
		$starter_count++ if $league->{Players}->{$Player}->{status} eq "Starter";

		## name test
		my $name = $league->{Players}->{$Player}->{name};
		like($name, qr/^[a-zA-Z0-9]*$/, "$name is alphanumeric");
	}

	is($sub_count, 5, "We have 5 substitutes");
	is($starter_count, 10, "We have 10 substitutes");

	note "The league is: \n" . Dumper $league;
	## we are done testing
	done_testing();
}


## invoke test
test_roster_bots;
