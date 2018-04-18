#!/usr/bin/perl -w
use strict;

# path to jpegtran
my $JPEGTRAN_LOC = '/Users/grkenn/src/jpeg_uniq/jpegtran';

# Somewhat Advanced Photo Dupe Finder
# Greg Kennedy 2012

# Identifies duplicate photos by image data:
#  strips EXIF info and converts to optimize + progressive
#  before performing MD5 on image data

# Requires "jpegtran" application from libjpeg project
#  Mac users: http://www.phpied.com/installing-jpegtran-mac-unix-linux/

use File::Find;
use Digest::MD5;

my %fingerprint;

my $ctx = Digest::MD5->new;

my $count = 0;

sub process
{
  my $filename = $_;

  # file is a directory
  if (-d $filename) { return; }
  # file is an OSX hidden resource fork
  if ($filename =~ m/^\._/) { return; }

  if ($filename =~ m/\.jpe?g$/i) {
    # attempt to use jpegtran to "normalize" jpg files
    if (system("$JPEGTRAN_LOC -copy none -optimize -progressive -outfile /tmp/find_dupe.jpg \"$filename\"")) {
      print STDERR "\tError normalizing file " . $File::Find::name . "\n\n";
    } else {
      $filename = '/tmp/find_dupe.jpg';
    }
  }

  # open file
  open (FP, $filename) or die "Couldn't open $filename (source " . $File::Find::name . "): $!\n";
  binmode(FP);
  # MD5 digest on file
  $ctx->addfile(*FP);
  push (@{$fingerprint{$ctx->digest}}, $File::Find::name);
  close(FP);

  # count / progress report
  $count ++;
  if ($count % 100 == 0)
  {
    print STDERR "Progress: $count...\n";
  }
}

## Main script
if (scalar @ARGV == 0)
{
  print "Usage: ./find_dupe.pl <folder> [<folder> ...]\n\tjpegtran MUST be in the path,\n\tor edit the script and set JPEGTRAN_LOC to an absolute location\n";
  exit;
}

find(\&process, @ARGV);

print "Duplicates report:\n";

foreach my $md5sum (keys %fingerprint)
{
  if (scalar @{$fingerprint{$md5sum}} > 1)
  {
    print "--------------------\n";
    foreach my $fname (@{$fingerprint{$md5sum}})
    {
      print $fname . "\n";
    }
  }
}
