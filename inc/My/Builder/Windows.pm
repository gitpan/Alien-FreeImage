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
  
    rename 'Source/LibJXR/common/include/guiddef.h', 'Source/LibJXR/common/include/guiddef.h.XXX' if -f 'Source/LibJXR/common/include/guiddef.h';

    my @cmd = ( $self->get_make, '-f', 'Makefile.mingw', "DISTDIR=$prefixdir", "FREEIMAGE_LIBRARY_TYPE=STATIC", "all" );
    warn "[cmd: ".join(' ',@cmd)."]\n";
    $self->do_system(@cmd) or die "###ERROR### [$?] during make ... ";
    
    rename 'Source/LibJXR/common/include/guiddef.h.XXX', 'Source/LibJXR/common/include/guiddef.h' if -f 'Source/LibJXR/common/include/guiddef.h.XXX';
  }
  else {
    die "only gcc is supported on MSWIn32";
  }
}

sub get_make {
  my ($self) = @_;
  my @try = ( 'gmake', 'mingw32-make', 'make', $Config{make}, $Config{gmake} );
  warn "Gonna detect make:\n";
  foreach my $name ( @try ) {
    next unless $name;
    warn "- testing: '$name'\n";
    if (system("$name --help 2>nul 1>nul") != 256) {
      # I am not sure if this is the right way to detect non existing executable
      # but it seems to work on MS Windows (more or less)
      warn "- found: '$name'\n";
      return $name;
    };
  }
  warn "- fallback to: 'dmake'\n";
  return 'dmake';
}

sub quote_literal {
    my ($self, $txt) = @_;
    $txt =~ s|"|\\"|g;
    return qq("$txt");
}

1;
