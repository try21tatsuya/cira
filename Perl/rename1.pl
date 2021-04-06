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
    next if ($file eq '.');
    next if ($file eq '..');
    my $new_file = join('_', ($entry, $file));
    rename("$entry\/$file", "$entry\/$new_file") or die "rename false. $!";
  }
}
