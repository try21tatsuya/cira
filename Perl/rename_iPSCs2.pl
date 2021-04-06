use strict;
use warnings;
use File::Copy;

my $input_dir = '.';
mkdir 'out';
opendir(DIR, $input_dir) or die "$input_dir: $!";
foreach my $entry (readdir(DIR)) {
  next if ($entry eq '.');
  next if ($entry eq '..');
  next if ($entry eq 'out');
  next if (not -d $entry);
  opendir(DIR2, $entry) or die "$entry: $!";
  foreach my $file (readdir(DIR2)) {
    next if ($file eq '.');
    next if ($file eq '..');
    if ($file =~ /tif$/) {
      my $new_file = join('_', ($entry, $file));
      copy("$entry\/$file", "$input_dir\/$new_file") or die "rename false. $!";
      move("$new_file", "out");
    }
  }
}
closedir(DIR);
closedir(DIR2);
