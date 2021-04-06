use strict;
use warnings;

my $input_dir = '.';
opendir(DIR, $input_dir) or die "$input_dir: $!";
open(FILE, 'filenames.csv') or die "$!";
my @filenames = <FILE>;
my @new_filenames = ();
foreach my $filename (@filenames) {
  $filename =~ s/,/_/g;
  $filename =~ s/\x0D?\x0A?$//;
  push(@new_filenames, "$filename");
}
#print @new_filenames;
my $count = 0;
my @entry = (readdir(DIR));
foreach my $entry (@entry) {
  next if ($entry eq '.');
  next if ($entry eq '..');
  next if ($entry =~ /.csv$/);
  next if ($entry =~ /.pl$/);
  rename("$entry", "$new_filenames[$count].tif") or die "rename false. $!";
  $count ++;
}

closedir(DIR);
close(FILE);
