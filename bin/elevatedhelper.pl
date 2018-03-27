#!/usr/bin/perl

use LoxBerry::System;
use CGI;
use warnings;
use strict;

our $cgi = CGI->new;
$cgi->import_names('R');
my  $version = "0.1.1";

if ($R::action eq "kodiautostart") {
	if (is_enabled($R::key)) {
		system("systemctl enable kodi");
	} elsif (is_disabled($R::key)) {
		system("systemctl disable kodi");
	}
	print $cgi->header(-type => 'application/json;charset=utf-8',
					-status => "200 OK");
	print "{status: 'OK'}";
	exit;
}

if ($R::action eq "change") {
	my $success;
	if ($R::key eq "licvc1") {
		$success = replace_str_in_file("/boot/config.txt", "decode_WVC1=", "decode_WVC1=$R::value");
	}
	if ($R::key eq "licmpeg2") {
		$success = replace_str_in_file("/boot/config.txt", "decode_MPG2=", "decode_MPG2=$R::value");
	}

	if ($success) {
		print $cgi->header(-type => 'application/json;charset=utf-8',
					-status => "200 OK");
		print "{status: 'OK', error: 0, key: '$R::key', value: '$R::value'}";
	} else {
		print $cgi->header(-type => 'application/json;charset=utf-8',
					-status => "500 Error");
		print "{status: 'Error', error: 1, key: '$R::key', value: '$R::value'}";
	}
	exit;

}






	print $cgi->header(-type => 'application/json;charset=utf-8',
					-status => "501 Action not implemented");
	print "{status: 'Not implemented'}";

exit;


sub replace_str_in_file
{
	my ($filename, $findstr, $replacestr) = @_;
	
	my $newfilestr;
	my $foundstr;
	
	exit 0 if (! $filename || ! $findstr);
	
	eval {

		open(my $fh, '<', $filename)
		  or warn "Could not open file for reading: '$filename' $!";
		  
		while (my $row = <$fh>) {
			if (begins_with($row, $findstr)) {
				print STDERR "Found string - rewriting it";
				$newfilestr .= "$replacestr\n";
				$foundstr = 1;
			} else {
				$newfilestr .= $row;
			}
		}
		close $fh;
		if (! $foundstr) {
			print STDERR "Adding missing string";
			$newfilestr .= "$replacestr\n";
		}
		
		open($fh, '>', $filename)
			or warn "Could not open file for writing: '$filename' $!";
		print $fh $newfilestr;
		close $fh;
		
	};
	if ($@) {
		print STDERR "Something failed writing the new entry to file $filename.";
		exit 0;
	}

	exit 1;

}
