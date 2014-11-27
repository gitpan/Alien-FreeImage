package Alien::FreeImage;

use warnings;
use strict;

use Alien::FreeImage::ConfigData;
use File::ShareDir qw(dist_dir);
use File::Spec::Functions qw(catdir);

=head1 NAME

Alien::FreeImage - Building freeimage library - L<http://freeimage.sourceforge.net/>

=cut

our $VERSION = '0.001';

=head1 VERSION

Version 0.001 of Alien::FreeImage uses I<freeimage> sources XXXX.

=head1 SYNOPSIS

B<IMPORTANT:> This module is not a perl binding for I<freeimage> library; it is just a helper module.

Alien::FreeImage installation comprise of these steps:

=over

=item * Build I<freeimage> binaries from source codes (note: static libraries are build in this case)

=item * Install binaries and dev files (*.h, *.a) into I<share> directory of Alien::FreeImage distribution - I<share>
directory is usually something like this: /usr/lib/perl5/site_perl/5.10/auto/share/dist/Alien-FreeImage

=back

Later on you can use Alien::FreeImage in your module that needs to link with I<freeimage> like this:

 # Sample Makefile.pl
 use ExtUtils::MakeMaker;
 use Alien::FreeImage;

 WriteMakefile(
   NAME         => 'Any::FreeImage::Module',
   VERSION_FROM => 'lib/Any/FreeImage/Module.pm',
   LIBS         => Alien::FreeImage->config('LIBS'),
   INC          => Alien::FreeImage->config('INC'),
   # + additional params
 );

B<IMPORTANT:> As Alien::FreeImage builds static libraries the modules using Alien::FreeImage need to have 
Alien::FreeImage just for building, not for later use. In other words Alien:FreeImage is just "build dependency"
not "run-time dependency".

=head1 METHODS

=head2 config()

This function is the main public interface to this module.

 Alien::FreeImage->config('LIBS');

Returns a string like: '-L/path/to/freeimage/dir/lib -lfreeimage'

 Alien::FreeImage->config('INC');

Returns a string like: '-I/path/to/freeimage/dir/include'

 Alien::FreeImage->config('PREFIX');

Returns a string like: '/path/to/freeimage/dir'

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 COPYRIGHT

2014+ KMX E<lt>kmx@cpan.orgE<gt>

=cut

sub config
{
  my ($package, $param) = @_;
  return unless ($param =~ /[a-z0-9_]*/i);
  my $subdir = Alien::FreeImage::ConfigData->config('share_subdir');
  my $share_dir = dist_dir('Alien-FreeImage');
  my $real_prefix = catdir($share_dir, $subdir);
  my $val = Alien::FreeImage::ConfigData->config('config')->{$param};
  return unless $val;
  $val =~ s/\@PrEfIx\@/$real_prefix/g; # handle @PrEfIx@ replacement
  return $val;
}

1;
