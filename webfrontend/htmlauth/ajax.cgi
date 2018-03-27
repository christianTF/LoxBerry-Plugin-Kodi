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
		system("sudo systemctl enable kodi");
	} elsif (is_disabled($R::key)) {
		system("sudo systemctl disable kodi");
	}
	print $cgi->header(-type => 'application/json;charset=utf-8',
					-status => "200 OK");
	print "{status: 'OK'}";
	exit;
}

if ($R::action eq "change") {
	my $success;
	if ($R::key eq "licvc1" || $R::key eq "licmpeg2") {
		print qx { sudo $lbpbindir/elevatedhelper.pl action=change key=$R::key value=$R::value };
	}
	exit;

}

if ($R::action eq "query") {
	print qx { sudo $lbpbindir/elevatedhelper.pl action=query };
	exit;
}




	print $cgi->header(-type => 'application/json;charset=utf-8',
					-status => "501 Action not implemented");
	print "{status: 'Not implemented'}";

exit;

