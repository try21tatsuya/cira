use strict;
use warnings;
use File::Copy;

open(NEWFILE, '> Organoid_results.csv') or die "$!";
print NEWFILE 'Cell_line,Passage,Start,Cell_density,Condition_1,Condition_2,Condition_3,Condition_4,CHIR_hr,Day,Component,Organoid,Hoechst,NPHS1,LTL,EpCAM,LTL_and_EpCAM,notLTL_and_EpCAM,NPHS1_or_EpCAM,NPHS1/Hoechst,LTL/Hoechst,EpCAM/Hoechst,LTL_and_EpCAM/Hoechst,notLTL_and_EpCAM/Hoechst,NPHS1_or_EpCAM/Hoechst,LTL/EpCAM,notLTL/EpCAM,NPHS1/NPHS1_or_EpCAM,LTL/NPHS1_or_EpCAM,notLTL/NPHS1_or_EpCAM', "\n";

my $input_dir = '.';
opendir(DIR, $input_dir) or die "$input_dir: $!";
foreach my $entry (readdir(DIR)) {
  my $new_entry = $entry;
  $new_entry =~ s/_/,/g;
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
      @rows = splice(@rows, 1, 7);
      my @data = ($new_entry);
      foreach my $row (@rows) {
        my @numbers = split(/,/, $row);
        push(@data, $numbers[2]);
      }
      $data[8] = $data[2] / $data[1] * 100;
      $data[9] = $data[3] / $data[1] * 100;
      $data[10] = $data[4] / $data[1] * 100;
      $data[11] = $data[5] / $data[1] * 100;
      $data[12] = $data[6] / $data[1] * 100;
      $data[13] = $data[7] / $data[1] * 100;
      $data[14] = $data[5] / $data[4] * 100;
      $data[15] = $data[6] / $data[4] * 100;
      $data[16] = $data[2] / $data[7] * 100;
      $data[17] = $data[5] / $data[7] * 100;
      $data[18] = $data[6] / $data[7] * 100;
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
