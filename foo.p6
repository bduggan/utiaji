my %a =
    first => [1,2,3],
    second => [4,5,6]
;

say ( %a<first>.list Z %a<second>.list ).perl;

for %a<first>.list Z %a<second>.list -> ( $x,$y ) {
    say 'got';
    say $x, $y;
}
