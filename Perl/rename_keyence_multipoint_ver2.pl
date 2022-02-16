use strict;
use warnings;
use File::Copy;

my $start_time = time; # 開始時間

my $input_dir = '.'; #カレントディレクトリで実行する
mkdir 'out'; #まず出力先のディレクトリを作成
opendir(DIR, $input_dir) or die "$input_dir: $!";
foreach my $section (readdir(DIR)) { #「撮影年月日_サンプル回収年月日(Unique_ID_embedding_date)_サンプル番号(Unique_ID_block_number)_切片番号_CH1_CH2_CH3_CH4_撮影条件(default=1)」のディレクトリ毎に処理する
  next if ($section eq '.');
  next if ($section eq '..');
  next if ($section eq 'out');
  next if (not -d "$input_dir\/$section"); #単なる文字列ではなくディレクトリを指定する場合は、上位のディレクトリからのパスを明示する必要がある
  opendir(DIR2, "$input_dir\/$section") or die "$section: $!";
  foreach my $file (readdir(DIR2)) {
    next if ($file eq '.');
    next if ($file eq '..');
    next if ($file =~ /bcf/);
    next if ($file =~ /Overlay.tif/);
    if ($file =~ /tif$/) {
      my @fname = split(/_/, $file); # ファイル名から、一連の画像の何視野目かを抽出する
      my $new_dname = join('_', ($section, $fname[1]));
      unless (-d "$input_dir\/out\/$new_dname") { # $new_dnameのディレクトリが存在しなければ、mkdirする
        mkdir "$input_dir\/out\/$new_dname";
      }
      my $new_fname = $fname[2]; # ImageJマクロで開くために、ファイル名を「CH1.tif」などと短くしておく。
      copy("$input_dir\/$section\/$file", "$input_dir\/out\/$new_dname\/$new_fname") or die "rename false. $!"; #一旦カレントディレクトリにファイルをコピー（パスは明示する）
    }
  }
}
closedir(DIR);
closedir(DIR2);

my $end_time = time; # 終了時間
my $process_time = $end_time - $start_time; # 経過秒数

print "ok\n";
print "process time= $process_time sec\n";
