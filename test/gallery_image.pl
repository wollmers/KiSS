use strict;
use warnings;

use lib qw< ../lib>;

use Kiss::Gallery::Image;

use Data::Dumper;

use Cwd 'abs_path';
use File::Spec;

my $home = abs_path('../');
print '$home: ',$home,"\n";

my $object = Kiss::Gallery::Image->new($home);

print 'home: ',$object->home(),"\n";
print 'folder: ',$object->folder(),"\n";

my $sizes = $object->sizes();
print 'sizes: ',Dumper($sizes),"\n";

my $tree = $object->convert_all();




