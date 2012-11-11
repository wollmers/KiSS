package Kiss::Gallery;

use strict;
use warnings;

use v5.10.1;

use File::Path;

sub new {
	my $class = shift;
	my $self = {};
	bless($self, $class);
	
	return $self;
}

sub Extensions {
	my $self = shift;
	#use File::Type::WebImages 'mime_type';
	return qw ( jpg jpeg gif png );
}

sub HumanFilesize {
	my $self = shift;
	my $bytes = shift;
	
	my ($Size,$Ext);

	$Size = sprintf("%0.2f",($bytes/1024)); $Ext = "KB";

	if ($Size > 1024) {
		$Size = sprintf("%0.2f",($Size/1024)); $Ext = "MB";
	}
	return ($Size,$Ext);
}

sub parseGalleryTemplate {
	my $self = shift;
	my $object = shift;
	my $tmpl = shift;

	return $tmpl;
}

sub parse {
	my $self = shift;

	my @ct = ();
	my $cnt = 0;
	my %objpos = ();
	my %posobj = ();
	my @objs;
	
	# Next/Back Navigation of Gallery 
	for my $object (@objs) {
	}

	return $o;
}

sub getFolderAbs {
	my $self = shift;
	
}

sub getFolderHttp {
	my $self = shift;

	
}

sub DefaultPrefs {
	my $self = shift;
}

sub readBase {	
	my $self = shift;
}

sub setName {
	my $self = shift;
	my $name = shift;
}

sub getGalleryList {
	my $self = shift;
}

sub addGallery {
	my $self = shift;

}

sub addObject {
	my $self = shift;

}

sub getObjects {	
	my $self = shift;

}

sub remove {	
	my $self = shift;

	my @objects = $self->getObjects();
	
	for $object ( @objects ) {
		my $err = $object->remove();
		if ($err) {
			warn $@;
			last;
			return $@;
		}		
	}
	return;
}

sub newObject {
	my $self = shift;
	my $id = shift;
	my $obj = Kiss::Gallery::Image->new();
	return $obj;
}


