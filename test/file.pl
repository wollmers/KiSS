use strict;
use warnings;

use lib qw< ../lib>;

use Kiss::File;

use Data::Dumper;

use Benchmark ':all';

use Cwd 'abs_path';
my $abs_path = abs_path('../lib');
print '$abs_path: ',$abs_path,"\n";

#my $tree = Kiss::File->new();

#sub read_dir {
  opendir (my $fh,'../lib');
  my @readdirs = readdir $fh;
  closedir $fh;
  print '@readdirs: ',Dumper(\@readdirs),"\n";
#}

sub tree_dir {
  my @dirs = Kiss::File->new()->tree('../lib');
}

sub tree_new {
  my @dirs = Kiss::File->new();
}

=comment

cmpthese(1000, {
   'read_dir' => sub { read_dir(); },
   'tree_dir' => sub { tree_dir(); },
   'tree_new' => sub { tree_new(); },
});

=cut




