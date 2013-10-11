use Time::Local;
sub to_epoch {
  my ($t) = @_; 
  my ($y, $d, $m) = ($t =~ /(\d{4})-(\d{2})-(\d{2})/);
  return timelocal(0, 0, 0, $d+0, $m-1, $y-1900);
}
sub diff_days {
  my ($t1, $t2) = @_; 
  return (abs(to_epoch($t2) - to_epoch($t1))) / 86400;
}

print diff_days($ARGV[0], $ARGV[1]), "\n";
