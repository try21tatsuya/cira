use strict;
use warnings;
use File::Copy;

my $start_time = time; # 開始時間

my $input_dir = '.'; #カレントディレクトリで実行する
mkdir 'out'; #まず出力先のディレクトリを作成
opendir(DIR, $input_dir) or die "$input_dir: $!";
foreach my $Experiment_ID (readdir(DIR)) { #「Experiment_ID」のディレクトリ毎に処理する
  next if ($Experiment_ID eq '.');
  next if ($Experiment_ID eq '..');
  next if ($Experiment_ID eq 'out');
  next if (not -d "$input_dir\/$Experiment_ID"); #単なる文字列ではなくディレクトリを指定する場合は、上位のディレクトリからのパスを明示する必要がある
  opendir(DIR2, "$input_dir\/$Experiment_ID") or die "$Experiment_ID: $!";
  foreach my $Acquisition_date (readdir(DIR2)) {
    next if ($Acquisition_date eq '.');
    next if ($Acquisition_date eq '..');
    next if (not -d "$input_dir\/$Experiment_ID\/$Acquisition_date");
    opendir(DIR3, "$input_dir\/$Experiment_ID\/$Acquisition_date") or die "$Acquisition_date: $!";
    foreach my $file (readdir(DIR3)) {
      next if ($file eq '.');
      next if ($file eq '..');
      if ($file =~ /tif$/) {
        my @fname = split(/_/, $file); # ファイル名から、ディレクトリ内の何枚目の画像かを抽出する
        my $new_fname = join('_', ($Experiment_ID, $Acquisition_date, 1, $fname[1]));
        copy("$input_dir\/$Experiment_ID\/$Acquisition_date\/$file", "$input_dir\/out\/$new_fname") or die "rename false. $!"; #ファイルをコピー（パスは明示する）
      }
    }
  }
}
closedir(DIR);
closedir(DIR2);
closedir(DIR3);

my $end_time = time; # 終了時間
my $process_time = $end_time - $start_time; # 経過秒数

print "ok\n";
print "process time= $process_time sec\n";