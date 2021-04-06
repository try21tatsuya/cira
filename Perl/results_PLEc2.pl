use strict;
use warnings;
use File::Copy;

open(NEWFILE, '> total_results.csv') or die "$!";
print NEWFILE 'Organoid,Hoechst,PODXL,LTL,Ecad,LTL(+)_and_Ecad(+),LTL(-)_and_Ecad(+),LTL(+)_or_Ecad(+),PODXL(+)_or_LTL(+)_or_Ecad(+),PODXL(+)_and_(LTL(+)_or_Ecad(+)),PODXL/Hoechst(%),LTL/Hoechst(%),Ecad/Hoechst(%),LTL(+)_and_Ecad(+)/Hoechst(%),LTL(-)_and_Ecad(+)/Hoechst(%),LTL(+)_or_Ecad(+)/Hoechst(%),PODXL(+)_or_LTL(+)_or_Ecad(+)/Hoechst(%),PODXL(+)_and_(LTL(+)_or_Ecad(+))/Hoechst(%)', "\n";

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
    if ($new_file =~ /csv$/) {
      open(FILE, "$entry\/$new_file") or die "$!\n";
      my @rows = <FILE>;
      @rows = splice(@rows, 1, 9);
      my @data = ($entry);
      foreach my $row (@rows) {
        my @numbers = split(/,/, $row);
        push(@data, $numbers[2]);
      }
      $data[10] = $data[2] / $data[1] * 100;
      $data[11] = $data[3] / $data[1] * 100;
      $data[12] = $data[4] / $data[1] * 100;
      $data[13] = $data[5] / $data[1] * 100;
      $data[14] = $data[6] / $data[1] * 100;
      $data[15] = $data[7] / $data[1] * 100;
      $data[16] = $data[8] / $data[1] * 100;
      $data[17] = $data[9] / $data[1] * 100;
      my $data = join(',', @data);
      #print $data, "\n";
      print NEWFILE $data, "\n";
      close(FILE);
    }
  }
}
closedir(DIR);
closedir(DIR2);
close(NEWFILE);
