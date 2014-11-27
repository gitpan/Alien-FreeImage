package My::Builder::Windows;

use strict;
use warnings;
use base 'My::Builder';

use Config;

sub make_clean {
  my $self = shift;
  $self->do_system( $self->get_make, '-f', 'Makefile.mingw', "clean" );
}

sub make_inst {
  my ($self, $prefixdir) = @_;
  $prefixdir =~ s|\\|/|g; # gnu make does not like \
  
  if($Config{cc} =~ /gcc/) {
    my @cmd = ( $self->get_make, '-f', 'Makefile.mingw', "DISTDIR=$prefixdir", "FREEIMAGE_LIBRARY_TYPE=STATIC", "all" );
    warn "[cmd: ".join(' ',@cmd)."]\n";
    $self->do_system(@cmd) or die "###ERROR### [$?] during make ... ";
  }
  else {
    die "only gcc is supported on MSWIn32";
  }
}

sub get_make {
  my ($self) = @_;
  my @try = ( 'gmake', 'mingw32-make', 'make', $Config{make}, $Config{gmake} );
  print STDERR "Gonna detect make:\n";
  foreach my $name ( @try ) {
    next unless $name;
    print STDERR "- testing: '$name'\n";
    if (system("$name --help 2>nul 1>nul") != 256) {
      # I am not sure if this is the right way to detect non existing executable
      # but it seems to work on MS Windows (more or less)
      print STDERR "- found: '$name'\n";
      return $name;
    };
  }
  print STDERR "- fallback to: 'dmake'\n";
  return 'dmake';
}

sub quote_literal {
    my ($self, $txt) = @_;
    $txt =~ s|"|\\"|g;
    return qq("$txt");
}

1;