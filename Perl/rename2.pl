use strict;
use warnings;

my $input_dir = '.';
opendir(DIR, $input_dir) or die "$input_dir: $!";
foreach my $entry (readdir(DIR)) {
  next if ($entry eq '.');
  next if ($entry eq '..');
  next if (not -d $entry);
  opendir(DIR2, $entry) or die "$entry: $!";
  foreach my $file (readdir(DIR2)) {
    if ($file =~ /CH1.tif$/) {
      rename("$entry\/$file", "$entry\/CH1.tif") or die "rename false. $!";
    } elsif ($file =~ /CH2.tif$/) {
      rename("$entry\/$file", "$entry\/CH2.tif") or die "rename false. $!";
    } elsif ($file =~ /CH3.tif$/) {
      rename("$entry\/$file", "$entry\/CH3.tif") or die "rename false. $!";
    } elsif ($file =~ /CH4.tif$/) {
      rename("$entry\/$file", "$entry\/CH4.tif") or die "rename false. $!";
    } else {
      next;
    }
  }
}

closedir(DIR);
closedir(DIR2);
