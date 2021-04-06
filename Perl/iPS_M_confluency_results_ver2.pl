use strict;
use warnings;

open(NEWFILE, '> iPS_M_results.csv') or die "$!";
print NEWFILE 'Cell_line,Passage,Start,Day,Field,Total_area_mm2,Confluency', "\n";

my $input_dir = '.';
opendir(DIR, $input_dir) or die "$input_dir: $!";
foreach my $file (readdir(DIR)) {
  next if ($file eq '.');
  next if ($file eq '..');
  next if (-d $file);
  next if ($file eq 'iPS_M_results.csv');
  if ($file =~ /csv$/) {
    open(FILE, "$file") or die "$!\n";
    my @rows = <FILE>;
    my @second_row = split(/,/, $rows[1]);
    my $file_name = $second_row[0];
    $file_name =~ s/_/,/g;
    my @file_name = split(/,/, $file_name);
    my @data = ();
    push(@data, $file_name[0]);
    push(@data, $file_name[1]);
    push(@data, $file_name[2]);
    push(@data, $file_name[4]);
    push(@data, $file_name[6]);
    push(@data, $second_row[2] / 2.76);
    push(@data, $second_row[4]);
    my $data = join(',', @data);
    print NEWFILE $data;
    close(FILE);
  }
}

closedir(DIR);
close(NEWFILE);
