package Kiss::Gallery::Description;

use strict;
use warnings;

use v5.10.1;

use File::Spec;
use Data::Dumper;

#use parent qw( Kiss::Gallery );

sub new {
	my $class = shift;
	my $home = shift;
	my $self = {};
	bless($self, $class);
	
	$self->home($home);
	
	return $self;
}

sub home {
  my $self = shift;
  my $home = shift;
  
  if (defined $home && -d $home) { 
    $self->{home} = $home;
  } 
  if (defined $self->{home}) {
    return $self->{home}; 
  }
  elsif (defined $ENV{'DOCUMENT_ROOT'}) {
    $self->{home} = $ENV{'DOCUMENT_ROOT'};
  }
  return $self->{home};
}

sub folder {
	my $self = shift;

  if (defined $self->{folder}) {
    return $self->{folder};
  }
  $self->{folder} = $self->home() . '/' . 'pub/gallery';
	return $self->{folder};
}


sub descriptions {
  my $self = shift;
  
  if (exists $self->{descriptions}) {
    return $self->{descriptions};
  }
  
  my $path = $self->folder();
  
  my $encoding = 'utf-8';
  my $file = "$path/.description.csv";
  open( my $fh, "<:encoding($encoding)", $file)  or print STDERR "failed opening $file \n";
    my $order = 0;
    while (my $line = <$fh>) {
      $order++;
      chomp $line;
      my ($filename,$title,$description) = split(/[|]/,$line,3);
      $self->{descriptions}->{$filename} = {
        name => $filename,
        title => $title, 
        description => $description,
        order => $order,
      };
    }
    close($fh);

  return $self->{descriptions};
  
=comment

  opendir (my $dh, $path) or die "Cannot open directory: ".$path." $!";;
  my @items = grep { $_ !~ /^\.[.]?$/ } readdir $dh;
  closedir $dh;
  
  my @files = grep { -f "$path/$_" && /\.JPG$/i } @items;
  
  print '@files: ',Dumper(\@files),"\n";
  for my $file (@files) {
    $self->variations("$path/$file");
  }
  
=cut
  
}

1;

