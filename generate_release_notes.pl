#!/usr/bin/perl
#
# working horse for generating a release log from git log messages. The log messages
# are forwarded via stdin by the calling script.
# This script will extract some log message lines with a configured tag (e.g. 'NEW') and
# populate a list of changed items (the release log) with the respective messages.
# If a message starts with one of the defined tags (e.g. 'NEW'), it will be added as
# a release log item in the section corresponding to the tag.
# Multiple lines are joined into one release log item. Thus, every release log item must
# be terminated by a blank line (or EOF).
# Leading dashes are ignored. Thus, a message like "  - NEW Added feature XY" will become
# a release log item "- Added feature XY" in the NEW section.
#
# @author Alexander Eck-Zimmer
# @date 2014-08-06

use strict;

###########################################
# CONFIG START
###########################################

# header labels for the sections
my %headings = (
	'NEW' => 'New Features',
	'FIX' => 'Bugfixes',
	'CHANGE' => 'Other Changes',
	'TEXT' => 'Cosmetic Changes',
);

# define order (and appearance) of sections
# you may omit any section here, then it will be 
# ignored in the output
my @sections = qw/ NEW FIX CHANGE TEXT /;

# mapping from log message keywords --> Release log section
# The value must be one of the defined. A prefix which is not
# listed here will not be recognized by the parser
my %sectionMapping = (
	'NEW' => 'NEW',
	'FIX' => 'FIX',
	'CHG' => 'CHANGE',
	'TXT' => 'TEXT',
	'FEATURE' => 'NEW',
	'BUGFIX' => 'FIX',
	'CHANGE' => 'CHANGE',
	'TEXT' => 'TEXT',
);

###########################################
# CONFIG END
###########################################

# command line parameters
if (! $ARGV[0]) {
	print "ERROR mandatory parameter VERSION missing\n";
	exit 1;
}

if (! $ARGV[1]) {
	print "ERROR mandatory parameter RELEASE_DATE missing\n";
	exit 1;
}

my ($version, $releaseDate) = ($ARGV[0], $ARGV[1]);

# ---------------------------------------------------------
# checks the config
#
# @return {integer} 0 (false) if there are config errors,
#   1 if no errors have been found
# ---------------------------------------------------------
sub checkConfig {
	my $ok = 1;
	
	# a section in the "order of sections" list must be a valid section
	for my $tag (@sections) {
		if (!exists $headings{$tag}) {
			error("configuration error: \@sections mentions section [$tag], which is missing in \%headings.");
			$ok = 0;
		}
	}
	
	# a section mapping must point to one of the defined sections
	while (my ($key, $value) = each %sectionMapping) {
		if (!exists $headings{$value}) {
			error("configuration error: \%sectionMapping defines a mapping [$key -> $value], but the target section [$value] is missing in \%headings.");
			$ok = 0;
		}
	}
	
	return $ok;
}

# ---------------------------------------------------------
# displays an error message on STDERR
#
# @param message {string} the error message
# ---------------------------------------------------------
sub error {
	my ($message) = @_;
	
	print STDERR "ERROR ".$message."\n";
}


# ---------------------------------------------------------
# trims white space at beginning and end of line
#
# @param line {string} the line to be trimmed
# @return {string} same as parameter line, with leading and
#   trailing whitespace trimmed
# ---------------------------------------------------------
sub trim {
	my ($line) = @_;
	
	$line =~ s/^\s*(.*)\s*$/\1/g;
	return $line;
}

# ---------------------------------------------------------
# returns string formatted as title
#
# @param text {string} the text to be displayed as title
# @return {string} text, enriched with control code for a 
#   proper formatting as title
# ---------------------------------------------------------
sub title {
	my ($text) = @_;
	
	return "## $text\n\n";
}


# ---------------------------------------------------------
# returns string formatted as subtitle
#
# @param text {string} the text to be displayed as subtitle
# @return {string} text, enriched with control code for a 
#   proper formatting as subtitle
# ---------------------------------------------------------
sub subtitle {
	my ($text) = @_;
	
	return "$text\n\n";
}


# ---------------------------------------------------------
# returns string formatted as section header
#
# @param text {string} the text to be displayed as header
# @return {string} text, enriched with control code for a 
#   proper formatting as section header
# ---------------------------------------------------------
sub header {
	my ($text) = @_;
	
	return  "### $text\n\n";
}


# ---------------------------------------------------------
# returns string formatted as log item
#
# @param text {string} the text to be displayed as item
# @return {string} text, enriched with control code for a 
#   proper formatting as log item
# ---------------------------------------------------------
sub item {
	my ($text) = @_;
	
	return  "- $text\n";
}

# check config
if (!checkConfig()) {
	exit 1;
}

# structure to collect the log messages in relation to their respective section
my %log;
$log{$_} = [] for @sections;

# collect relevant log messages
my @message = (); # currently collected message (section, message). It will be flushed (written)
# when an empty line follows or at EOF
while (<STDIN>) {
	my $line = $_;
	chomp $line;

	if (@message) {
		# we are currently "collecting", i.e. we already have begun a release note item and
		# are now waiting for an empty line or EOF which would indicate the end of this item
		if ($line =~ m/^\s*$/) {
		# blank line => stop collecting
			push @{$log{$message[0]}}, $message[1];
			@message = ();
		} else {
			# no blank line => continue collecting until blank line is found
			$message[1] .= ' '.trim($line);
		}

	} else {
		# not collecting => look for start of release log message (beginning with a tag)
		for my $tag (keys %sectionMapping) {
			if ($line =~ m/^(?:\s*-?\s*)?$tag (.*)$/) {
				my $msg = $1;
				@message = ($sectionMapping{$tag}, trim($msg));
			}
		}
	}
}
# flush currently collecting message, if any
if (@message) {
	push @{$log{$message[0]}}, $message[1];
}

my @output = ();

for my $tag (@sections) {
 	if (scalar @{$log{$tag}}) {
		my @msg = ();
		
		push @msg, header($headings{$tag});
		
		for my $l (@{$log{$tag}}) {
			push @msg,  item($l);
		}

		push @output, join('', @msg);
	}
}

# output result
print title("Release $version");
print subtitle("Release date: $releaseDate");

print join("\n", @output);
