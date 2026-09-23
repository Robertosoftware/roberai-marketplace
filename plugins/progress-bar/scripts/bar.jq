# Shared renderer: bar(percent; width) -> colored "▓▓▓░░░ 42%"
def rep($s; $n): if $n > 0 then $s * $n else "" end;
def bar($pct; $width):
  ($pct // 0 | round | if . < 0 then 0 elif . > 100 then 100 else . end) as $p
  | (($p * $width + 50) / 100 | floor) as $f
  | (if $p >= 90 then "31" elif $p >= 70 then "33" else "32" end) as $c
  | "\u001b[\($c)m" + rep("▓"; $f) + rep("░"; $width - $f) + "\u001b[0m \($p)%";
