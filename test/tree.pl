use strict;
use warnings;

use lib qw< ../lib>;

use Kiss::File;

use Data::Dumper;

use Cwd 'abs_path';
my $abs_path = abs_path('../lib');
print '$abs_path: ',$abs_path,"\n";

my $object = Kiss::File->new();
my $tree = $object->tree($abs_path);

print 'tree: ',Dumper($tree),"\n";

#my @test = grep { $_ !~ /^\.[.]?$/} qw< . .. foo>;
#print 'test: ',Dumper(\@test),"\n";

