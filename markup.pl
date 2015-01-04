#!/usr/bin/perl

use warnings;
use utf8;
use strict;

my %label_mapping = (
	"Intro stage" => ".intro",
	"Wire Sponge" => ".sponge",
	"Wheel Gator" => ".gator",
	"Flame Stag" => ".stag",
	"Magna Centipede" => ".centipede",
	"Crystal Snail" => ".snail",
	"Overdrive Ostrich" => ".ostrich",
	"Bubble Crab" => ".crab",
	"Morph Moth" => ".moth",
	"Violen" => ".violen",
	"Serges" => ".serges",
	"Agile" => ".agile",
	"Boss Repeats" => ".teleporter",
	"Sigma" => ".sigma");

while (my $line = <>)
{
	if ($line !~ m#//#)
	{
		$line =~ s/ /,\$/g;
		$line = "\tdb \$$line";
	}
	elsif ($line =~ m#//\s*\d+\.\s*(.*)$#)
	{
		my $comment = $1;
		foreach my $key (keys(%label_mapping))
		{
			my $regex = "^" . $key;
			if ($comment =~ m/$regex/)
			{
				print("$label_mapping{$key}:\n");
			}
		}
		$line = "\t$line";
	}
	elsif ($line ne "")
	{
		$line = "\t$line";
	}
	print($line);
}
