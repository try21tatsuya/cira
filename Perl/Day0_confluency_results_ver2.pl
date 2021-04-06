use strict;
use warnings;

open(NEWFILE, '> Day0_confluency_results.csv') or die "$!";
print NEWFILE 'Cell_line,Passage,Start,Cell_density,Day,Well,Field,Crop,Total_area_mm2,Confluency', "\n";

my $input_dir = '.';
opendir(DIR, $input_dir) or die "$input_dir: $!";
foreach my $file (readdir(DIR)) {
  next if ($file eq '.');
  next if ($file eq '..');
  next if (-d $file);
  next if ($file eq 'Day0_confluency_results.csv');
  if ($file =~ /csv$/) {
    open(FILE, "$file") or die "$!\n";
    my @rows = <FILE>;
    my @second_row = split(/,/, $rows[1]);
    my $file_name = $second_row[0];
    $file_name =~ s/_/,/g;
    my @file_name = split(/,/, $file_name);
    my @numbers = split(/,/, $rows[2]);
    my @data = ();
    push(@data, $file_name[0]);
    push(@data, $file_name[1]);
    push(@data, $file_name[2]);
    push(@data, $file_name[3]);
    push(@data, $file_name[4]);
    push(@data, $file_name[5]);
    push(@data, $file_name[7]);
    push(@data, $file_name[10]);
    push(@data, $numbers[2] / 2.76);
    push(@data, $numbers[4]);
    my $data = join(',', @data);
    print NEWFILE $data;
    close(FILE);
  }
}

closedir(DIR);
close(NEWFILE);
