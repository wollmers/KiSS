package Kiss::Gallery;

use strict;
use warnings;

use v5.10.1;

use File::Path;

sub new {
	my $class = shift;
	my $self = {};
	bless($self, $class);

	if (!exists( $self->{init}->{Defs}{cms}{PATH}{ATFILESABS} ) ) {		
		die "Config error: please add to cms_config.pm section 'PATH' -> ATFILESABS + ATFILESHTTP ";	
	}

	unless (-d $self->getFolderAbs()) {
		mkdir ( $self->getFolderAbs() ) 
		  or die "Cannot create directory: ".$self->getFolderAbs()." $!";
	}
	
	return $self;
}

sub getAllowedExtensions {
	my $self = shift;
	return qw ( jpg jpeg gif png );
}

sub _getHumanFilesize {
	my $self = shift;
	my $Bytes = shift;
	my ($Size,$Ext);

	$Size = sprintf("%0.2f",($Bytes/1024)); $Ext = "KB";

	if ($Size > 1024) {
		$Size = sprintf("%0.2f",($Size/1024)); $Ext = "MB";
	}
	
	return ($Size,$Ext);
}

sub _parseGalleryTemplate {
	my $self = shift;
	my $object = shift;
	my $tmpl = shift;

	my $id = $object->getID();
	$tmpl =~ s/_{IMAGEID}_/$id/g;

	my $imgsrc_s = $object->getFolderHttp()."/_s_".$object->getObjectValue('filename');
	$tmpl =~ s/_{IMGHTTPSRC\:S}_/$imgsrc_s/g;

	my $imgsrc_m = $object->getFolderHttp()."/_m_".$object->getObjectValue('filename');
	$tmpl =~ s/_{IMGHTTPSRC\:M}_/$imgsrc_m/g;
		
	my $imgsrc_l = $object->getFolderHttp()."/_l_".$object->getObjectValue('filename');
	$tmpl =~ s/_{IMGHTTPSRC\:L}_/$imgsrc_l/g;

	my $fn = $object->getObjectValue('filename');
	$tmpl =~ s/_{FILENAME}_/$fn/g;
		
	my $t = $object->getObjectValue('title' );
	$tmpl =~ s/_{TITLE}_/$t/g;

	my $desc = $object->getObjectValue('description' );
	$tmpl =~ s/_{DESCRIPTION}_/$desc/g;

	my $origfile = $object->getFolderAbs()."/".$object->getObjectValue('filename');
	if (-f $origfile) {
		my $size = (stat($origfile))[7];
		my ($sv,$se) = $self->_getHumanFilesize( $size );
		
		$tmpl =~ s/_{FILESIZE}_/$sv $se<\/a>/g;
	
		my $link2src = $object->getFolderHttp()."/".$object->getObjectValue('filename');
		$tmpl =~ s/_{LINKTOSRC}_(.*)_{\/LINKTOSRC}_/<a href="$link2src" target="_blank">$1<\/a>/g;
	}

	return $tmpl;
}

############################

sub parse {
	my $self = shift;

	my $x = 1;

	my $o = qq|<!-- GALLERY |.$self->getID().qq| -->
			   <div class="gallery" id="gallery|.$self->getID().qq|">
			   	<a name="galleryID|.$self->getID().qq|"></a>
			  |;
					
	my $style = admintool::CMS::GALLERY::STYLE->new( $self->{init}, $self->getBaseValue('styleID') );	
	
	if (defined( $self->{init}->{cgi}->param('gImageID') )) {
		my $object = admintool::CMS::GALLERY::Object->new( $self->{init}, $self->{init}->{cgi}->param('gImageID') );
		$o .= $self->_parseGalleryTemplate( $object, $style->get('stylelarge') );
		my @objs = $self->getObjects( 1 );

		my @ct = ();
		my $cnt = 0;
		my %objpos = ();
		my %posobj = ();
		
		# die Vor/Zurueck und Navigation der Gallery erzeugen
		for my $object (@objs) {
			++$cnt;
			$objpos{ $object->getID() } = $cnt;
			$posobj{ $cnt } = $object->getID();			
			
			if ($self->{init}->{cgi}->param('gImageID') == $object->getID() ) {
				push @ct, $cnt;
			}
			else {
				push @ct, qq|<a href="?gImageID=|.$object->getID().qq|#galleryID|.$self->getID().qq|">|.$cnt.qq|</a>|;			
			}
		}

		$o .= qq|<br />|;
		
		if ($objpos{ $self->{init}->{cgi}->param('gImageID') } > 1) {
			unshift @ct, qq|<a href="?gImageID=|.$posobj{ ($objpos{ $self->{init}->{cgi}->param('gImageID') }-1) }.qq|#galleryID|.$self->getID().qq|">&lt;&lt;</a>|;
		}
		else {
			unshift @ct, qq|&lt;&lt;|;
		}
		
		if (($objpos{ $self->{init}->{cgi}->param('gImageID') }-1) < $#objs) {
			push @ct, qq|<a href="?gImageID=|.$posobj{ ($objpos{ $self->{init}->{cgi}->param('gImageID') }+1) }.qq|#galleryID|.$self->getID().qq|">&gt;&gt;</a>|;
		}
		else {
			push @ct, qq|&gt;&gt;|;
		}
		
		$o .= qq|<div align="center">|.join (" ", @ct ).qq|</div>|;
		
		return $o.qq|</div>|;
	}

	$o .= qq|<table class="gallery">|;

	$rowitems = $style->get('columns');
	
	for my $object ( $self->getObjects( 1 ) ) {
		my $tmpl2 = $self->_parseGalleryTemplate( $object, $style->get('styledef') );
		
		if ($x == 1) {
			$o .= qq|<tr>|;
		}
		
		$o .= qq|<td>|.$tmpl2.qq|</td>|;
	
		if ($x == $rowitems) {
			$o .= qq|</tr>|;
			$x = 1;
			next;
		}
		
		++$x;
	}
	
	my $colspan = $rowitems-$y;
	if ($colspan >= 1) {
		$o .= qq|<td colspan="|.$colspan.qq|"></td>|;
		$o .= qq|</tr>|;
	}
	
	$o .= qq|</table>
			 </div>
			|;

	return $o;
}

sub getFolderAbs {
	my $self = shift;
	return $self->{init}->{Defs}{cms}{PATH}{ATFILESABS}."/galleries";
	
}

sub getFolderHttp {
	my $self = shift;
	return $self->{init}->{Defs}{cms}{PATH}{ATFILESHTTP}."/galleries";
	
}

sub setID {
	my $self = shift;
	$self->{ID} = shift;
	return $self->{ID};
}

sub getID {
	my $self = shift;
	return $self->{ID};
}

sub _getDefaultPrefs {
	my $self = shift;

	$self->{rowitems} = 2;
	$self->{itemtemplate} = "_{GALLERYIMG}_";

}

sub readBase {	
	my $self = shift;
	my $db = $self->{init}->{Defs}{dbh}->{cms};
	
	if ($self->getID > 0) {	
		my $sql = "SELECT `gallery_name`,`UID`,`GID`,`PERMS`,`styleID`, `sortby`, `sortdesc`,`lang`,`parserID` ".
				  "FROM gallery ".
				  "WHERE ID=".$db->db_quote( $self->getID() );
		
		my @dbout = $db->db_array( $sql );
		
		$self->_getDefaultPrefs();
		
		if ($dbout[0] > 0) {
			$self->{name} = $dbout[1][0][0];			
			$self->{UID} = $dbout[1][0][1];
			$self->{GID} = $dbout[1][0][2];
			$self->{PERMS} = $dbout[1][0][3];
			$self->{styleID} = $dbout[1][0][4];
			$self->{sortby} = $dbout[1][0][5];
			$self->{sortdesc} = $dbout[1][0][6];
			$self->{lang} = $dbout[1][0][7];
			$self->{parserID} = $dbout[1][0][8];
		}
		else {
			$self->{name} = "";
			$self->{UID} = "";
			$self->{GID} = "";
			$self->{PERMS} = "";
			$self->{styleID} = 0;
			$self->{sortby} = "";
			$self->{sortdesc} = 0;
			$self->{parserID} = 0;
		}
	}
	else {
		$self->{name} = "";
		$self->{UID} = "";
		$self->{GID} = "";
		$self->{PERMS} = "";
		$self->{styleID} = 0;		
		$self->{sortby} = "";
		$self->{sortdesc} = 0;
		$self->{parserID} = 0;
	}	
}

sub set {
	my $self = shift;
	my %vals = %{ shift @_ };
	my $db = $self->{init}->{Defs}{dbh}->{cms};
	
	my $v = join ", ", map { "`".$_."`=".$db->db_quote( $vals{$_} ) } keys %vals;
	
	if ($v ne "") {
		my $sql = "UPDATE gallery ".
				  "SET ".$v." ".
				  "WHERE ID=".$self->getID();
		
		my $dbz = $db->db_do( $sql );
	}
	
	$self->readBase();
}

sub setName {
	my $self = shift;
	my $name = shift;
	my $db = $self->{init}->{Defs}{dbh}->{cms};
	my $sql = "UPDATE gallery ".
			  "SET gallery_name=".$db->db_quote( $name )." ".
			  "WHERE ID=".$db->db_quote( $self->getID() );
	
	my $dbz = $db->db_do( $sql );

	if ($dbz > 0) {
		$self->{name} = $db->db_quote( $name );
	}
}

sub getBaseValue {
	my $self = shift;
	my $key = shift;
	if ( exists( $self->{$key} ) ) {
		return $self->{$key};
	}	
}


sub getGalleryList {
	my $self = shift;
	my $db = $self->{init}->{Defs}{dbh}->{cms};
	my $sql = "SELECT ID, gallery_name, UID, GID, PERMS, lang ".
			  "FROM gallery ".
			  "WHERE 1 ".
			  "ORDER BY lang,gallery_name";
	
	my @dbout = $db->db_array( $sql );
	return @{ $dbout[1] };
}

sub addGallery {
	my $self = shift;
	my $gname = shift;
	my $uid = shift || 0;
	my $gid = shift || 0;
	my $db = $self->{init}->{Defs}{dbh}->{cms};
	
	my $sql = "INSERT INTO gallery ( ID, `gallery_name`,`UID`,`GID`) ".
			  "VALUES (NULL, ".$db->db_quote($gname).", ".$db->db_quote($uid).", ".$db->db_quote($gid).")";
	
	my $dbz = $db->db_do( $sql );
	if ($dbz > 0) {
		return $db->db_lastinsertid();
	}
	else {
		return -1;
	}
}

sub addObject {
	my $self = shift;
	my $uid = shift;
	my $gid = shift;
	my $db = $self->{init}->{Defs}{dbh}->{cms};
	my $sql = "INSERT INTO gallery_objects (ID, galleryID, UID, GID, cDate, mDate ) ".
			  "VALUES (NULL, ".$db->db_quote( $self->getID() ).", ".$db->db_quote( $uid ).", ".$db->db_quote( $gid ).", NOW(), NOW() )";

	my $dbz = $db->db_do( $sql );
	if ($dbz > 0) {
		my $p = File::Spec->canonpath( $self->getFolderAbs."/".$self->getID() );
		unless (-d $p) {
			mkdir ( $p ) or die "Cannot create directory: ".$p." $!";
		}

		return $db->db_lastinsertid();
	}
	else {
		return -1;
	}
}

sub getObjects {	
	my $self = shift;
	my $onlyActive = shift || 0;
	
	@{ $self->{Objects} } = ();
	my $db = $self->{init}->{Defs}{dbh}->{cms};
	
	my $ORDERBY = "";
	if ( $self->getBaseValue('sortby') ne "") {
		if ($self->getBaseValue('sortby') eq "filename") {
			$ORDERBY = " ORDER BY `filename`";
		}
		elsif ($self->getBaseValue('sortby') eq "cDate") {
			$ORDERBY = " ORDER BY `cDate`";
		}
		elsif ($self->getBaseValue('sortby') eq "mDate") {
			$ORDERBY = " ORDER BY `mDate`";
		}
		elsif ($self->getBaseValue('sortby') eq "user") {
			$ORDERBY = " ORDER BY `sortpos`";
		}
			
		if ($ORDERBY ne "" && $self->getBaseValue('sortdesc') == 1) {
			$ORDERBY .= " DESC";
		}
	}
	
	my $sql = "SELECT ID, UID, GID FROM gallery_objects ".
			  "WHERE galleryID=".$db->db_quote( $self->getID() ). $ORDERBY;
			  
	my @dbout = $db->db_array( $sql );

	for ( @{ $dbout[1] } ) {
		push @{ $self->{Objects} }, admintool::CMS::GALLERY::Object->new( $self->{init}, ${$_}[0] );
	}
	
	return @{ $self->{Objects} };
}

sub remove {	
	my $self = shift;
	my $db = $self->{init}->{Defs}{dbh}->{cms};
	my @objects = $self->getObjects();
	
	for $object ( @objects ) {
		my $err = $object->remove();
		if ($err) {
			warn $@;
			last;
			return $@;
		}		
	}
	
	my $sql = "DELETE FROM gallery ".
			  "WHERE ID=".$db->db_quote( $self->getID() );
	
	my $dbz = $db->db_do( $sql );
	
	return;
}

sub getParserID {
	my $self = shift;
	return $self->{parserID};
}

sub newObject {
	my $self = shift;
	my $id = shift;
	my $obj = admintool::CMS::GALLERY::Object->new( $self->{init}, $id );
	return $obj;
}


