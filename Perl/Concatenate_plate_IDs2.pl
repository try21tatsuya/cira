use strict;
use warnings;

# 現在時刻を取得
my ($sec, $min, $hour, $mday, $month, $year, $wday, $yday, $isdst) = localtime;
my $str_time = sprintf("%04d%02d%02d%02d%02d", $year+1900, $month+1, $mday, $hour, $min); #ファイルを作成した年月日時分
my $new_file = 'Plate_IDs_' . $str_time . '.csv';

open(NEWFILE, '>', $new_file) or die "$!";
print NEWFILE 'Plate_ID_date,Plate_ID_number,Well_number,Row,Column,Cell_line,Vial,Passage,Start,Induction_protocol,NPC_stock,Stock_date,Wake_date,Suspension_day,Condition_1,Condition_2,Condition_3,Condition_4,Condition_5,Experiment_day,Treatment,Compound_plate_ID,Compound_plate_number,Dilution_date,Position,Biological_replicate,Technical_replicate', "\n";

my $input_dir = '.';
opendir(DIR, $input_dir) or die "$input_dir: $!";
foreach my $file (readdir(DIR)) {
  next if ($file eq '.');
  next if ($file eq '..');
  next if ($file eq $new_file);
  if ($file =~ /csv$/) {
    my $filename = $file;
    $filename =~ s/\./_\./g;
    my @filename = split(/_/, $filename);
    open(FILE, "$file") or die "$!\n";
    my @rows = <FILE>;
    shift @rows; # ヘッダー行を削除する
    foreach my $row (@rows) {
      $row = $filename[1] . ',' . $filename[2] . ',' . $row;
      print NEWFILE $row;
    }
    close(FILE);
  }
}

closedir(DIR);
close(NEWFILE);
