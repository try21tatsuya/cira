use strict;
use warnings;

open(NEWFILE, '> Organoid_sizes_suspension.csv') or die "$!";
print NEWFILE 'Cell_line,Passage,Start,Cell_density,Stock,Condition_1,Condition_2,Condition_3,Condition_4,Condition_5,Condition_6,Day,Organoid,Total_area_inches2,Long_diameter_um,Short_diameter_um,Circularity,AR,Roundness,Total_area_mm2', "\n";

my $input_dir = '.';
opendir(DIR, $input_dir) or die "$input_dir: $!";
foreach my $file (readdir(DIR)) {
  next if ($file eq '.');
  next if ($file eq '..');
  next if ($file =~ /^Organoid_sizes/);
  if ($file =~ /csv$/) {
    my $filename = $file;
    $filename =~ s/.tif/_/g;
    my @filename = split(/_/, $filename);
    open(FILE, "$file") or die "$!\n";
    my @rows = <FILE>;
    my @numbers = split(/,/, $rows[2]);
    @numbers = splice(@numbers, 0, 9);
    my @new_numbers = ();
    $new_numbers[0] = $filename[0];
    $new_numbers[1] = $filename[1];
    $new_numbers[2] = $filename[2];
    $new_numbers[3] = $filename[3];
    $new_numbers[4] = $filename[4];
    $new_numbers[5] = $filename[5];
    $new_numbers[6] = $filename[6];
    $new_numbers[7] = $filename[7];
    $new_numbers[8] = $filename[8];
    $new_numbers[9] = $filename[9];
    $new_numbers[10] = $filename[10];
    $new_numbers[11] = $filename[11];
    $new_numbers[12] = $filename[12];
    $new_numbers[13] = $numbers[1];
    $new_numbers[14] = $numbers[2] / 2.76 * 1000;
    $new_numbers[15] = $numbers[3] / 2.76 * 1000;
    $new_numbers[16] = $numbers[5];
    $new_numbers[17] = $numbers[6];
    $new_numbers[18] = $numbers[7];
    $new_numbers[19] = $numbers[1] / 7.6176;
    my $new_numbers = join(',', @new_numbers) . "\n";
    print NEWFILE $new_numbers;
    close(FILE);
  }
}

closedir(DIR);
close(NEWFILE);
