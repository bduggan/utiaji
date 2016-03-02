my @strs = (
    "Camelia is a butterfly",
    "two\n\npieces",
    "Camelia is a butterfly",
    "two\r\n\r\npieces",
    "first piece\n\nsomemore\n\nstuff\n\nhere\r\nand\n\nhere\n\n",
    "Only one piece\r\n\r\n",
    "also one piece\n\n",
);

for @strs -> $str {
    say "\nparsing: ";
    say $str.perl;
    my $found = first { .defined }, $str.index("\n\n"), $str.index("\r\n\r\n");
    defined($found) or do { say "not found"; next };
    say "found it at $found";
    my ($header,$body) = $str.split( / "\n\n" | "\r\n\r\n" /, 2, :skip-empty );
    say $header.perl;
    say $body.defined ?? $body.perl !! "no body";
}

say "Camelia is a butterfly".index("er");
