use strict;
use warnings;

# 現在時刻を取得
my ($sec, $min, $hour, $mday, $month, $year, $wday, $yday, $isdst) = localtime;
my $str_time = sprintf("%04d%02d%02d%02d%02d", $year+1900, $month+1, $mday, $hour, $min); #ファイルを作成した年月日時分
my $new_file = 'Organoid_sizes_suspension_' . $str_time . '.csv';

open(NEWFILE, '>', $new_file) or die "$!";
print NEWFILE 'Plate_ID_date,Plate_ID_number,Well_number,Data_acquisition_date,Data_acquisition_time,Total_area_inches2,Long_diameter_um,Short_diameter_um,Circularity,AR,Roundness,Solidity,Total_area_mm2,Objects', "\n";

my $input_dir = '.';
opendir(DIR, $input_dir) or die "$input_dir: $!";
foreach my $file (readdir(DIR)) {
  next if ($file eq '.');
  next if ($file eq '..');
  next if ($file eq $new_file);
  if ($file =~ /csv$/) {
    my $filename = $file;
    $filename =~ s/.tif/_/g;
    my @filename = split(/_/, $filename);
    open(FILE, "$file") or die "$!\n";
    my @rows = <FILE>;
    my $row_number = @rows; # CSVファイルの行数を数える
    my @numbers = split(/,/, $rows[$row_number-1]); # Areaで昇順にソートしているので、一番大きいオブジェクトだけ抽出する
    @numbers = splice(@numbers, 0, 9);
    $numbers[8] =~ s/\x0D?\x0A?$//; # 行の最後にあるSolidityの後ろに改行が入っているので、環境に依存しないで改行を削除する
    my @new_numbers = ();
    $new_numbers[0] = $filename[3];
    $new_numbers[1] = $filename[4];
    $new_numbers[2] = $filename[5];
    $new_numbers[3] = $filename[2]; # 0時を超える場合があるので、手動で入力した日付を利用する
    $new_numbers[4] = $filename[1];
    $new_numbers[5] = $numbers[1];
    $new_numbers[6] = $numbers[2] * (2160 / 22.5) * 1.625; # 22.5 inch = 2160 pixelで、1.625 μm/pixel、つまり156 μm/inchの換算
    $new_numbers[7] = $numbers[3] * (2160 / 22.5) * 1.625;
    $new_numbers[8] = $numbers[5];
    $new_numbers[9] = $numbers[6];
    $new_numbers[10] = $numbers[7];
    $new_numbers[11] = $numbers[8];
    $new_numbers[12] = $numbers[1] * (156/1000)**2; # mm2
    $new_numbers[13] = $row_number-1; # オブジェクトの個数
    my $new_numbers = join(',', @new_numbers) . "\n";
    print NEWFILE $new_numbers;
    close(FILE);
  }
}

closedir(DIR);
close(NEWFILE);