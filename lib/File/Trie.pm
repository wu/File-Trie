package File::Trie;
use Moose;

# VERSION

#_* Libraries
use Carp;
use File::Basename;
use File::Path;
use YAML::XS;

#_* POD

=head1 NAME

File::Trie - store data in a file in a directory tree using a trie of the id

=head1 DESCRIPTION

Given an id, this module will build a path for the id from a trie.
This allows you to store a very large number of files in a directory
tree without having too many files in any specific directory.

For more information on a trie, see:

  http://en.wikipedia.org/wiki/Trie

For example, if your id is 'abc', then the path would be stored to
'/a/b/c'.

There is also some special handling for ids that look like a filename,
i.e. those that have extensions.  For example, if your id was
'foo.yaml', the path would be '/f/o/o.yaml'.

=head1 SYNOPSIS

  my $trie = File::Trie->new( { root => '/foo' } );

  my $path = $trie->trie( "abcd.yaml" );
  #  $path = "/a/b/c/d.yaml"

  # write data to the file in /foo/a/b/c/d.yaml
  $trie->write( $data_h, 'abcd.yaml' );
  $trie->write( { 1 => 2, foo => 'bar' }, 'abcde.yaml' );

  # read data back in again from /foo/a/b/c/d.yaml
  my $data = $trie->read( 'abcd.yaml' );

=cut

#_* Attributes

=head1 ATTRIBUTES

=over 8

=item root

The root directory for the directory tree.  All files will be written
or read under this directory.  This is required.

=cut

has 'root' => ( is       => 'ro',
                isa      => 'Str',
                required => 1,
            );

=item maxdepth

The maximum number of directory levels to create.  For example, if the
id is 'abcde.yaml', and maxdepth is set to 2, the path returned would
be '/a/b/cde.yaml'.  Defaults to unlimited directory levels.

=cut

has 'maxdepth' => ( is => 'ro',
                    isa => 'Num',
                    default => 0,
                );

=item bytes

The number of characters to use in each directory structure.  For
example, if the id is 'abcde.yaml', and bytes is set to 2, the path
returned would be '/ab/cd/e.yaml'.  Defaults to 1.

=cut

has 'bytes' => ( is => 'ro',
                 isa => 'Num',
                 default => 1,
             );

=back

=cut

#_* Methods

=head1 METHODS

=over 8

=item $obj->trie( $id )

Builds a path from a trie of the id.

For example, if the id were 'abc.yaml', the trie path would be
'/a/b/c.yaml'.

=cut

sub trie {
    my ( $self, $orig_id ) = @_;

    unless ( $orig_id ) {
        carp( "ERROR: trie called without an id" );
    }

    my $count = 0;

    my $id = $orig_id;
    $id =~ s|\..*$||;

    my $length = length( $id );

    my $bytes = $self->bytes;

    my $path = "";
  LETTER:
    while ( 1 ) {
        my $letter = substr( $id, $count, $bytes );

        $count += length( $letter );

        $path .= "/$letter";

        if ( $self->maxdepth ) { last if $count - 1 >= $self->maxdepth }
        last if $count >= $length;
    }

    $path .= substr( $orig_id, $count );

    return $path;
}

=item $obj->write( $data, $id )

Given a data reference and an id, write the data to a .yaml file in
the directory tree.

If the file already exists, it will be overwritten. with the new data.

=cut

sub write {
    my ( $self, $data, $id ) = @_;

    unless ( $data ) {
        carp( "ERROR: write() called with no data" );
    }

    unless ( $id ) {
        carp( "ERROR: write() called with no id" );
    }

    my $path = $self->_get_filename_mkdir( $id );

    YAML::XS::DumpFile( $path, $data );
}

=item $obj->read( $id )

Read the specified id's yaml file from the directory tree and return
the loaded data.

=cut

sub read {
    my ( $self, $id ) = @_;

    unless ( $id ) {
        carp( "ERROR: read() called with no id" );
    }

    my $path = $self->_get_filename_mkdir( $id );

    return YAML::XS::LoadFile( $path );
}



sub _get_filename_mkdir {
    my ( $self, $id ) = @_;

    my $filename = $self->trie( "$id.yaml" );

    my $dir = join( "/", $self->root, dirname( $filename ) );
    unless ( -d $dir ) {
        mkpath( $dir );
    }

    my $path = join( "/", $self->root, $filename );
    return $path;
}

#_* End

__PACKAGE__->meta->make_immutable;

1;

__END__

#_* Notes

=head1 NOTES

The performance may be poor if the ids are long (e.g. 32 chars or
more) and maxdepth is not specified, as this will result in creating a
very large number of directories each time an item is inserted.

It probably goes without saying, but when reading files from disk, you
must have maxdepth and bytes set to the same value as they were set
when the data was inserted.
