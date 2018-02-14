#!/usr/bin/perl
#
####################################################################################################
#                                                                                                  #
#  a short script to generate a bookmarkfile for the SDR-Program GQRX from a Sennheiser WSM-file.  #
#  Tested with gqrx version 2.10                                                                   #
#                                                                                                  #
####################################################################################################


use strict;
use warnings;
use XML::Simple;
use Data::Dumper;
use File::HomeDir;
use Getopt::Long;

my $input = "";
GetOptions('i|input=s' => \$input) or die "perl $0 --i ./WSM-File.wsm\n";

if ($input eq "")
{
        print "Bitte ein WSM-File angeben!\nDie Eingabe muss folgendermaßen lauten:\nperl $0 --i ./WSM-File.wsm\n";
        exit
}


#define how the output should look like, in my case every line should look like this:
#   638300000; Regie                    ; WFM (mono)          ;     120000; Mikrofone

my $lenfreq = 9;          # define length of frequency
my $demod = "WFM (mono)"; # define demodulation
my $bandwith = 120000;    # define the bandwith
my $tag = "Mikrofone";    # define the tag

my $home = sprintf File::HomeDir->my_home; #
my $path = '/.config/gqrx/';               # konfigurationsfile Linux
my $filename = 'bookmarks.csv';            # file in das die Bookmarks angehängt werden
my $file = "$home$path$filename";

my $counter = "0";

$demod = sprintf "%-20s", $demod;       #fill demodulation type with ending whitespaces 
$bandwith = sprintf "%10s", $bandwith;  #fill bandwith with leading whitespaces 

# create object
my $xml = new XML::Simple;

# read XML file
my $data = $xml->XMLin("$input");

open(my $fh, '>>', $file) or die "Konnte die Datei nicht öffnen '$file' $!";
foreach my $device (@{$data->{Device}})
{
        my $ip = $device->{IPAddress};
        print $fh "# $ip\n";
        foreach my $receiver (@{$device->{Receiver}})
        {
                my $freq = $receiver->{CurrentFrequency};
                my $name = $receiver->{Name};
                my $lenfreqakt = length($freq);
                if ($lenfreqakt < $lenfreq)
                {
                        $freq = (10**($lenfreq - $lenfreqakt)) * $freq;
                }
                $freq = sprintf "%12s" ,$freq;
                $name = sprintf "%-25s", $name; #define length of name field here!!!
                print $fh  join "; " , ( $freq , $name , $demod , $bandwith , $tag);
                print $fh "\n";
                $counter = $counter + 1;
        }
}
close $fh;
print "\nFertig!\nEs wurden $counter Frequenzen in die Datei $file exportiert.\n\n";
