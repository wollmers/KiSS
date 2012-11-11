package Kiss::File;

#use File::Find::Rule;
#use File::Path qw(make_path remove_tree);
use File::Spec;
#use File::Basename;
#use File::Type::WebImages 'mime_type';

use Data::Dumper;

sub new {
    my $class = shift;
    
    my $self = {};
    bless $self, $class;
    return $self;
}

sub home {
  my $self = shift;
  
  if (defined $self->{tree}) {
    $self->{home} = $self->{tree}->[0]->{dirs}->[0]->{path}; 
  }
  elsif (defined $ENV{'DOCUMENT_ROOT'}) {
    $self->{home} = $ENV{'DOCUMENT_ROOT'};
  }
  return $self->{home};
}

sub tree {
  my $self = shift;
  my $root = shift || $self->home();
  
  $self->{tree} = [{ dirs => [ {name => '/', path => $root, rel => '/'}]}];
  $self->dir($self->{tree}->[0]->{dirs}->[0]);
  
  return $self->{tree};
}

sub dir {
  my $self = shift;
  my $current = shift;

  my $path = $current->{path};
  opendir (my $fh, $path);
  my @items = grep { $_ !~ /^\.[.]?$/ } readdir $fh;
  closedir $fh;
  
  my @files = grep { -f "$path/$_" } @items;
  my @dirs  = grep { -d "$path/$_" } @items;
  
  #$current->{files} = [] if @files;
  #$current->{dirs} = [] if @dirs;
  
  for my $file (@files) {
    push @{$current->{files}}, {name => $file, path => $path.'/'.$file, , rel => $current->{rel}.'/'.$file };
  }
  for my $dir (@dirs) {
    push @{$current->{dirs}}, {name => $dir, path => $path.'/'.$dir, rel => $current->{rel}.'/'.$dir};  
  }
  for my $child ( @{$current->{dirs}} ) {
    $self->dir($child);
  }
}

sub breadcrumb {}

sub menue {
  my $self    = shift;
  my $active  = shift;
  my $current = shift || $self->{tree}->[0];
  my @levels = @_ ? @_ : ('/',File::Spec->splitdir(File::Spec->abs2rel($active, $self->home())));
  
  
  my (undef,$abs_path,undef) = File::Spec->splitpath($active);
  my $html = '';
  my $level = shift @levels;
  
  for my $dir ( @{$current->{dirs}} ) {
    my @classes;
    my $content = '';
    if ($dir->{name} eq $level) {
      push @classes,'active';
      if (@levels) {
        $content =
          '<ul>'."\n" 
          . $self->menue($active, $dir, @levels)
          . '</ul>'."\n";
      }
    }
    if (exists $dir->{dirs} && @{$dir->{dirs}} > 0 || 
      exists $dir->{files} && @{$dir->{files}} > 0) {
      push @classes,'has_children';
    }
    $html .= '<li class="'
      . join(' ', @classes)
      . '">'
      . '<a href="'
      . File::Spec->abs2rel($dir->{path} . '/index.html', $abs_path)
      .'">' . $dir->{name} . '</a>' . "\n"
      . $content
      . '</li>'."\n";
    if (@levels == 1) {
      for my $file ( @{$dir->{files}} ) {
        my @classes;
        if ($file->{name} eq $level) {
          push @classes,'active';
        }
        my $name = $file->{name};
        $name =~ s/\.html$//;
        $html .= '<li class="'
          . join(' ', @classes)
          . '">'
          . '<a href="'
          . File::Spec->abs2rel($file->{path},$abs_path) 
          .'">' . $file->{name} . '</a>'
          . '</li>' . "\n" if ($name !~ /^index$/);  
      }
    }
    if ($dir->{name} eq '/') {
      $html = '<ul>'."\n".$html.'</ul>'."\n";
    }
  }

  return $html; 
}


1;

