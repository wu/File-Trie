package File::Trie;
use Moose;

use File::Basename;
use File::Path;
use YAML::XS;

has 'root' => ( is       => 'ro',
                isa      => 'Str',
                required => 1,
            );

has 'maxdepth' => ( is => 'ro',
                    isa => 'Num',
                    default => 0,
                );

has 'bytes' => ( is => 'ro',
                 isa => 'Num',
                 default => 1,
             );

sub write {
    my ( $self, $data, $key ) = @_;

    my $path = $self->_get_filename_mkdir( $key );

    YAML::XS::DumpFile( $path, $data );
}

sub read {
    my ( $self, $key ) = @_;

    my $path = $self->_get_filename_mkdir( $key );

    return YAML::XS::LoadFile( $path );
}

sub _get_filename_mkdir {
    my ( $self, $key ) = @_;

    my $filename = $self->trie( "$key.yaml" );

    my $dir = join( "/", $self->root, dirname( $filename ) );
    unless ( -d $dir ) {
        mkpath( $dir );
    }

    my $path = join( "/", $self->root, $filename );
    return $path;
}

sub trie {
    my ( $self, $orig_key ) = @_;

    my $count = 0;

    my $key = $orig_key;
    $key =~ s|\..*$||;

    my $dir = "";
  LETTER:
    while ( my $letter = substr( $key, $count, $self->bytes ) ) {

        if ( $letter eq "." ) {
            last LETTER;
        }

        $count += length( $letter );

        $dir .= "/$letter";

        if ( $self->maxdepth ) { last if $count eq $self->maxdepth }
    }

    my $path = $dir;
    $path .= substr( $orig_key, $count );

    return $path;
}

1;
