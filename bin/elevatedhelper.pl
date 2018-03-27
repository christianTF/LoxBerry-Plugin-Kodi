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
	print '{"status":"OK", "error":0}';
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
		print "{\"status\":\"OK\", \"error\": 0, \"key\": \"$R::key\", \"value\": \"$R::value\"}";
	} else {
		print $cgi->header(-type => 'application/json;charset=utf-8',
					-status => "500 Error");
		print "{\"status\": \"Error\", \"error\": 1, \"key\": \"$R::key\", \"value\": \"$R::value\"}";
	}
	exit;

}

if ($R::action eq "query") {
	my $mpeg2lic = find_str_in_file("/boot/config.txt", "decode_MPG2=");
	# print STDERR "TEST $mpeg2lic\n";
	my $vc1lic = find_str_in_file("/boot/config.txt", "decode_WVC1=");
	
	my $piserial = trim(find_str_in_file("/proc/cpuinfo", "Serial\t\t:"));
	$piserial = "Not found" if (! $piserial);
	
	my ($dummympeg2, $mpeg2status) = split(/=/, qx { vcgencmd codec_enabled MPG2 });
	my ($dummyvc1, $vc1status) = split(/=/, qx { vcgencmd codec_enabled WVC1 });
	chomp ($mpeg2status);
	chomp ($vc1status);
	
	
	#$mpeg2status = is_enabled($mpeg2status) ? 1 : 0;
	#$vc1status = is_enabled($vc1status) ? 1 : 0;
	
	
	
	
	
	print $cgi->header(-type => 'application/json;charset=utf-8',
					-status => "200 OK");
	print '{ ' . 
		'"mpeg2lic":"' . $mpeg2lic . '",' . 
		'"vc1lic":"' . $vc1lic . '",' . 
		'"piserial":"' . $piserial . '",' . 
		'"mpeg2status":"' . $mpeg2status . '",' . 
		'"vc1status":"' . $vc1status . '"' . 
	
	'}';
	exit;
	
	
	
	
	
}








	print $cgi->header(-type => 'application/json;charset=utf-8',
					-status => "501 Action not implemented");
	print '{"status": "Not implemented", "error":1}';

exit;


sub replace_str_in_file
{
	my ($filename, $findstr, $replacestr) = @_;
	
	my $newfilestr;
	my $foundstr;
	
	return 0 if (! $filename || ! $findstr);
	
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
		return 0;
	}

	return 1;

}

sub find_str_in_file
{
	my ($filename, $findstr) = @_;
	
	my $newfilestr;
	my $foundstr;
	my $strval;
	
	return undef if (! $filename || ! $findstr);
	
#	eval {

		open(my $fh, '<', $filename)
		  or warn "Could not open file for reading: '$filename' $!";
		  
		while (my $row = <$fh>) {
			if (begins_with($row, $findstr)) {
				print STDERR "Found string - parsing it\n";
				print STDERR "Length of $findstr: " . length($findstr) . "\n";
				chomp $row;
				$strval = substr ($row, length($findstr));
				print STDERR "Row   : $row \n";
				print STDERR "Strval: $strval \n";
				close $fh;
				return($strval);
			} 
			
		}
		close $fh;
		
#	};
	# if ($@) {
		# print STDERR "Something failed reading the the file $filename.";
		# return undef;
	# }

	return undef;

}

