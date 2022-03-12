use strict;
use warnings;
use File::Copy;

my $start_time = time; # 開始時間

# 現在時刻を取得
my ($sec, $min, $hour, $mday, $month, $year, $wday, $yday, $isdst) = localtime;
my $str_time = sprintf("%04d%02d%02d%02d%02d", $year+1900, $month+1, $mday, $hour, $min); #ファイルを作成した年月日時分
my $Org_file = 'Org_' . $str_time . '.csv';
my $Cyst_file = 'Cyst_' . $str_time . '.csv';

open(ORGFILE, '>', $Org_file) or die "$!";
print ORGFILE 'Experiment_date,Experiment_number,Acquisition_date,Acquisition_series,Variables,Acquisition_protocol,Image_number,Organoid_Area_inches2,Organoid_X,Organoid_Y,Organoid_Major,Organoid_Minor,Organoid_Angle,Organoid_Circularity,Organoid_AR,Organoid_Roundness,Organoid_Solidity', "\n";

open(CYSTFILE, '>', $Cyst_file) or die "$!";
print CYSTFILE 'Experiment_date,Experiment_number,Acquisition_date,Acquisition_series,Variables,Acquisition_protocol,Image_number,Cyst_ID,Cyst_Area_inches2,Cyst_X,Cyst_Y,Cyst_Major,Cyst_Minor,Cyst_Angle,Cyst_Circularity,Cyst_AR,Cyst_Roundness,Cyst_Solidity', "\n";

my $input_dir = '.'; #カレントディレクトリで実行する
opendir(DIR, $input_dir) or die "$input_dir: $!";
foreach my $file (readdir(DIR)) {
    next if ($file eq '.');
    next if ($file eq '..');
    if ($file =~ /csv$/) {
        open(FILE, "$input_dir\/$file") or die "$!\n"; # 先にファイルを開く
        my @rows = <FILE>;
        $file =~ s/\./\_/g; # ファイル名の'.'を'_'に置換する
        my @fname = split(/_/, $file); # 最初の7列には、ファイル名からの情報を記録
        @fname = splice(@fname, 0, 7);
        my $fname = join(',', @fname);
        # まず「Org.csv」を処理
        if ($file =~ /Org.csv$/) {
            my @numbers = split(/,/, $rows[1]);
            shift(@numbers); # 0列目の「1」を削除
            my $data = $fname . ',' . join(',', @numbers);
            print ORGFILE $data;
        }
        # 次に「Cyst.csv」を処理
        if ($file =~ /Cyst.csv$/) {
            shift(@rows); # 0行目を削除
            foreach my $row (@rows) {
                $row =~ s/[\r\n]//g; # 改行を削除する
                my $data = $fname . ',' . $row . "\n";
                print CYSTFILE $data;
            }
        }
        close(FILE);
    }
}
closedir(DIR);
close(ORGFILE);
close(CYSTFILE);

my $end_time = time; # 終了時間
my $process_time = $end_time - $start_time; # 経過秒数

print "ok\n";
print "process time= $process_time sec\n";