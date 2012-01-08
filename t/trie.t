#!/perl
use strict;

use File::Temp qw/ tempdir /;
use Test::More 'no_plan';

use File::Trie;

my $tempdir = tempdir( "/tmp/tmpdir-XXXXXXXXXX", CLEANUP => 1 );

{
    ok( my $trie = File::Trie->new( { root => $tempdir } ),
        "Creating a new File::Trie object"
    );

    is( $trie->trie( "abc.txt" ),
        "/a/b/c.txt",
        "Checking that abc.txt gets written to a/b/c.txt"
    );

    is( $trie->trie( "abc123.txt" ),
        "/a/b/c/1/2/3.txt",
        "Checking abc123.txt"
    );
}

{
    ok( my $trie = File::Trie->new( { root => $tempdir, maxdepth => 3 } ),
        "Creating a new File::Trie object with maxdepth 3"
    );

    is( $trie->trie( "abc.txt" ),
        "/a/b/c.txt",
        "Checking that abc.txt gets written to /a/b/c.txt with maxdepth 3"
    );

    is( $trie->trie( "abcd.txt" ),
        "/a/b/cd.txt",
        "Checking that abc.txt gets written to /a/b/cd.txt with maxdepth 3"
    );

    is( $trie->trie( "abc123.txt" ),
        "/a/b/c123.txt",
        "Checking abc123.txt with maxdepth 3"
    );
}

{
    ok( my $trie = File::Trie->new( { root => $tempdir, bytes => 2 } ),
        "Creating a new File::Trie object with bytes 2"
    );

    is( $trie->trie( "abc.txt" ),
        "/ab/c.txt",
        "Checking that abc.txt with bytes 2"
    );

    is( $trie->trie( "abcd.txt" ),
        "/ab/cd.txt",
        "Checking abcd.txt with bytes 2"
    );

    is( $trie->trie( "abcde.txt" ),
        "/ab/cd/e.txt",
        "Checking abcde.txt with bytes 2"
    );

    is( $trie->trie( "abcdefghijkl.txt" ),
        "/ab/cd/ef/gh/ij/kl.txt",
        "Checking abcdefghijkl.txt with bytes 2"
    );

}
