use strict;
use warnings;

use lib qw< ../lib>;

use Kiss::Gallery::Description;

use Data::Dumper;

use Cwd 'abs_path';
use File::Spec;

my $home = abs_path('../');
print '$home: ',$home,"\n";

my $object = Kiss::Gallery::Description->new($home);

print 'home: ',$object->home(),"\n";
print 'folder: ',$object->folder(),"\n";

my $descriptions = $object->descriptions();
print 'sizes: ',Dumper($descriptions),"\n";





