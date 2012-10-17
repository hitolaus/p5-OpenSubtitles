package OpenSubtitles;

$VERSION = "1.00";

use strict;
use LWP::Simple;
use XML::RPC;
use File::Basename;
use IO::Uncompress::Gunzip qw(gunzip $GunzipError) ;

# Globals
our $CANNED_RESPONSE; # Mock data for unit testing

#my $USER_AGENT = "p5-OpenSubtitles v1";
my $USER_AGENT = "OS Test User Agent";

sub new
{
	my($class, %args) = @_;

	my $self = bless({}, $class);

	return $self;
}

sub search
{
	my $self = shift;
    my $filename = shift or die("Need video filename");
    my $filesize = -s $filename;

	print $filename . " size: " . $filesize . "\n";

	my $token = _login();
    
	my @args = [ { sublanguageid => "eng", moviehash => OpenSubtitlesHash($filename), moviebytesize => $filesize } ];
    
	my $xmlrpc = XML::RPC->new('http://api.opensubtitles.org/xml-rpc');
	my $result = $xmlrpc->call('SearchSubtitles', $token, @args);
	
	return $result->{data};
}

sub download
{
	my $self = shift;
	my $filename = shift or die("Need video filename");
	
	my @result = $self->search($filename);
	
	if (@result == 0) {
		print "Cannot find subtitles for $filename\n";
		return;
	}
	
	my $subtitle = _best_subtitle(@result);
	
	my ( $name, $path, $suffix ) = fileparse( $filename, qr/\.[^.]*/ );
	
	my $subtitle_filename = "$path$name.$subtitle->{ext}";
	
	my $input = get($subtitle->{link});
	
	gunzip \$input => $subtitle_filename
	 	or die "gunzip failed: $GunzipError\n";
}

sub _best_subtitle
{
	my @subtitle = shift;
	
	# TODO: Call _is_subtitle_supported();
	
	return { link => $subtitle[0][0]->{SubDownloadLink}, ext =>  $subtitle[0][0]->{SubFormat} };
}

sub _is_subtitle_supported
{
	return 1;
}

sub _login
{
	my $xmlrpc = XML::RPC->new('http://api.opensubtitles.org/xml-rpc');
	my $result = $xmlrpc->call('LogIn', '', '', '',  $USER_AGENT );
	
	return $result->{token};
}


#################################################
# Hashing functions from opensubtitles.org
#################################################
sub OpenSubtitlesHash {
	my $filename = shift or die("Need video filename");

	open my $handle, "<", $filename or die $!;
	binmode $handle;

	my $fsize = -s $filename;

	my $hash = [$fsize & 0xFFFF, ($fsize >> 16) & 0xFFFF, 0, 0];

	$hash = AddUINT64($hash, ReadUINT64($handle)) for (1..8192);

	my $offset = $fsize - 65536;
	seek($handle, $offset > 0 ? $offset : 0, 0) or die $!;

	$hash = AddUINT64($hash, ReadUINT64($handle)) for (1..8192);

	close $handle or die $!;
	return UINT64FormatHex($hash);
}

sub ReadUINT64 {
		read($_[0], my $u, 8);
		return [unpack("vvvv", $u)];
}

sub AddUINT64 {
	my $o = [0,0,0,0];
	my $carry = 0;
	for my $i (0..3) {
		if (($_[0]->[$i] + $_[1]->[$i] + $carry) > 0xffff ) {
			$o->[$i] += ($_[0]->[$i] + $_[1]->[$i] + $carry) & 0xffff;
			$carry = 1;
		} else {
			$o->[$i] += ($_[0]->[$i] + $_[1]->[$i] + $carry);
			$carry = 0;
		}
	}
	return $o;
}

sub UINT64FormatHex {
	return sprintf("%04x%04x%04x%04x", $_[0]->[3], $_[0]->[2], $_[0]->[1], $_[0]->[0]);
}

1;

__END__

=head1 NAME

OpenSubtitles - OpenSubtitles.org integration

=head1 SYNOPSIS

  use OpenSubtitles;

  # ...

  my $sub = OpenSubtitles->new();

  my @result = $sub->search(...);

=head1 DESCRIPTION

C<OpenSubtitles> provides OpenSubtitles.org integration using their XML-RPC API.

=head2 METHODS

=over 2

=item search()

Search for subtitles

=item download()

Download and unzip the subtitle

=head1 AUTHOR

Jakob Hilarius, http://syscall.dk

=head1 COPYRIGHT AND LICENSE

Copyright 2012 by Jakob Hilarius, http://syscall.dk

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut