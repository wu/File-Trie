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

    my $data = { 1 => { 2 => 3 } };

    ok( $trie->write( $data, "abc" ),
        "Writing data structure to key 'abc'"
    );

    ok( -r "$tempdir/a/b/c.yaml",
        "Checking that a/b/c.yaml file found in $tempdir"
    );

    is_deeply( $trie->read( "abc" ),
               $data,
               "Reading data structure from key 'abc'"
               );

}
