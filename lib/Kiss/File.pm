package Kiss::File.pm

use File::Find::Rule;
use File::Path qw(make_path remove_tree);

use File::Spec;

use File::Basename;

use File::Type::WebImages 'mime_type';

sub home {
  my $self =shift;
  $self->{home} = $ENV{'DOCUMENT_ROOT'};
  return $self->{home};
}

sub tree {
  my $self = shift;
  my $root = shift //= $self->{home};
  
  
}
