use strict;
use warnings;
use File::Copy;

my $input_dir = '.'; #カレントディレクトリで実行する
mkdir 'out'; #ファイル出力先のディレクトリを作成
opendir(DIR, $input_dir) or die "$input_dir: $!";
foreach my $plate (readdir(DIR)) { #「撮影年月日_プレート作成日_プレート番号」のディレクトリ毎に処理する
  next if ($plate eq '.');
  next if ($plate eq '..');
  next if ($plate eq 'out');
  next if (not -d "$input_dir\/$plate"); #単なる文字列ではなくディレクトリを指定する場合は、上位のディレクトリからのパスを明示する必要がある
  opendir(DIR2, "$input_dir\/$plate") or die "$plate: $!";
  foreach my $field (readdir(DIR2)) { # 96ウェル分のディレクトリ毎に処理する
    next if ($field eq '.');
    next if ($field eq '..');
    next if (not -d "$input_dir\/$plate\/$field"); #「.lnk」ファイルは無視する
    opendir(DIR3, "$input_dir\/$plate\/$field") or die "$field: $!";
    foreach my $file (readdir(DIR3)) {
      next if ($file eq '.');
      next if ($file eq '..');
      if ($file =~ /tif$/) {
        my $mtime = (stat ("$input_dir\/$plate\/$field\/$file"))[9]; # statモジュールを用いてmtimeを取得（ファイルのパスを明示する必要がある）
        my ($sec, $min, $hour, $mday, $month, $year, $wday, $stime) = localtime($mtime);
        my $str_mtime = sprintf("%04d%02d%02d%02d%02d%02d", $year+1900, $month+1, $mday, $hour, $min, $sec); # 実際の撮影年月日・時間
        #print $str_mtime, "\n"; #動作確認用
        my $well_number = substr($file, 8, 2); #ファイル名からウェル番号のみ切り出し
        my $new_file = join('_', ($plate, $well_number, $str_mtime)) . '.tif'; #新しいファイル名を「撮影年月日_プレート作成日_プレート番号_ウェル番号_撮影時間」にする
        copy("$input_dir\/$plate\/$field\/$file", "$input_dir\/out\/$new_file") or die "rename false. $!"; #ファイルをコピー（パスを明示する必要がある）
      }
    }
    closedir(DIR3);
  }
  closedir(DIR2);
}
closedir(DIR);
