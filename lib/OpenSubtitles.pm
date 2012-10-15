package OpenSubtitles;

$VERSION = "1.00";

sub new
{
	my($class, %args) = @_;

	my $self = bless({}, $class);

	return $self;
}

sub search
{
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

=over 1

=item search()

Search for subtitles

=head1 AUTHOR

Jakob Hilarius, http://syscall.dk

=head1 COPYRIGHT AND LICENSE

Copyright 2012 by Jakob Hilarius, http://syscall.dk

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut