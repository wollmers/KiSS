use strict;
use warnings;

use lib qw< ../lib>;

use Kiss::File;

use Data::Dumper;

use Cwd 'abs_path';
use File::Spec;

my $home = abs_path('../home/');
print '$home: ',$home,"\n";

$ENV{'DOCUMENT_ROOT'} = $home;
#print '@levels: ',Dumper(\%ENV),"\n";


my $active = '/home/helmut/KiSS/home/archiv/archiv.html';
my $rel_home = File::Spec->abs2rel($active,$home);
my @levels = File::Spec->splitdir($rel_home);
#print '@levels: ',Dumper(\@levels),"\n";


my $object = Kiss::File->new();
my $tree = $object->tree($home);

#print 'tree: ',Dumper($tree),"\n";

my $nav = $object->menue($active);

print 'nav: ',Dumper($nav),"\n";


