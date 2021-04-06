use strict;
use warnings;
use File::Copy;

my $start_time = time; # 開始時間

# 現在時刻を取得
my ($sec, $min, $hour, $mday, $month, $year, $wday, $yday, $isdst) = localtime;
my $str_time = sprintf("%04d%02d%02d%02d%02d", $year+1900, $month+1, $mday, $hour, $min); #ファイルを作成した年月日時分
my $new_file = 'Sections_' . $str_time . '.csv';

open(NEWFILE, '>', $new_file) or die "$!";
print NEWFILE 'Acquisition_date,Experiment_date,Experiment_ID,Condition_ID,CH1,CH2,CH3,CH4,Replicate,Field,CH1_count,CH1_area_inches2,CH2_count,CH2_area_inches2,CH3_count,CH3_area_inches2,CH4_count,CH4_area_inches2,CH5_count,CH5_area_inches2,CH6_count,CH6_area_inches2,CH7_count,CH7_area_inches2,CH8_count,CH8_area_inches2,CH9_count,CH9_area_inches2', "\n";

my $input_dir = '.'; #カレントディレクトリ（outフォルダ）で実行する
opendir(DIR, $input_dir) or die "$input_dir: $!";
foreach my $entry (readdir(DIR)) {
  next if ($entry eq '.');
  next if ($entry eq '..');
  next if (not -d $entry);
  opendir(DIR2, $entry) or die "$entry: $!";
  foreach my $file (readdir(DIR2)) {
    next if ($file eq '.');
    next if ($file eq '..');
    if ($file =~ /csv$/) {
      open(FILE, "$entry\/$file") or die "$!\n";
      my @rows = <FILE>;
      @rows = splice(@rows, 1, 9);
      my @data = split(/_/, $entry); # 最初の9列には、ディレクトリ名からの情報（'Acquisition_date,...'）を記録
      foreach my $row (@rows) {
        my @numbers = split(/,/, $row);
        push(@data, $numbers[1]); # まず「Results.csv」中の「Count」の列を追加
        push(@data, $numbers[2]); # 次に「Results.csv」中の「Total Area」の列を追加
      }
      my $data = join(',', @data);
      print NEWFILE $data, "\n";
      close(FILE);
    }
  }
  closedir(DIR2);
}

closedir(DIR);
close(NEWFILE);

my $end_time = time; # 終了時間
my $process_time = $end_time - $start_time; # 経過秒数

print "ok\n",;
print "process time= $process_time sec\n";
