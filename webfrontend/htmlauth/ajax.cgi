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
	exit;



}



exit;
