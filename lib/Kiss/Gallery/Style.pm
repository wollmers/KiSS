package Kiss::Gallery::Style;

use parent qw( Kiss::Gallery );

sub new {
	my $class = shift;
	my $self = {};
	bless($self, $class);
	
	return $self;
}

sub setID {
	my $self = shift;
	$self->{_id} = shift;
}

sub getID {
	my $self = shift;
	return $self->{_id};
}	

sub readStyle {
	my $self = shift;
	my $db = $self->{init}->{Defs}{dbh}->{cms};	
	my $sql = "SELECT stylename,styledef,stylelarge,`columns`,UID,GID,PERMS, `size_s`,`size_m`,`size_l` ".
			  "FROM gallery_styles ".
			  "WHERE ID=".$db->db_quote( $self->getID() )." ".
			  "LIMIT 1";
						
	my @dbout = $db->db_array( $sql );
	if ($#{ $dbout[1] } >= 0 ) {
		$self->{v}{stylename} = $dbout[1][0][0];
		$self->{v}{styledef} = $dbout[1][0][1];
		$self->{v}{stylelarge} = $dbout[1][0][2];
		$self->{v}{columns} = $dbout[1][0][3];
		$self->{v}{UID} = $dbout[1][0][4];
		$self->{v}{GID} = $dbout[1][0][5];
		$self->{v}{PERMS} = $dbout[1][0][6];
		$self->{v}{size_s} = $dbout[1][0][7];
		$self->{v}{size_m} = $dbout[1][0][8];
		$self->{v}{size_l} = $dbout[1][0][9];
	}
	else {
		$self->{v}{UID} = $self->{init}->{ADMIN}->get_ID();
		$self->{v}{GID} = $self->{init}->{ADMIN}->{GID};
		$self->{v}{PERMS} = "wdpwdp---";
		$self->{v}{columns} = 1;
	}
}

sub get {
	my $self = shift;
	my $k = shift;
	if (exists( $self->{v}{ $k } ) ) {
		return $self->{v}{ $k };
	}
}

sub create {
	my $self = shift;
	my $db = $self->{init}->{Defs}{dbh}->{cms};
	
	my $sql = "INSERT INTO gallery_styles (ID,UID,GID,PERMS) ".
			  "VALUES (NULL, ".$db->db_quote( $self->{init}->{ADMIN}->get_ID() ).", 1, 'wdpwdp---')";
	
	### GID                ".$db->db_quote( $self->{init}->{ADMIN}->{GID} )."
	
	my $dbz = $db->db_do( $sql );
	my $lid = $db->db_lastinsertid();
	
	return $lid;
}

sub set {
	my $self = shift;
	my %vals = %{ shift @_ };
	my $db = $self->{init}->{Defs}{dbh}->{cms};
	
	for my $k ( keys %vals ) {
		if ($k eq "columns" && ( $vals{$k} <= 0 || $vals{$k} > 50 )) {
			$vals{$k} = 1;
		}
	}

	my $v = join ", ", map { "`".$_."`=".$db->db_quote( $vals{$_} ) } keys %vals;
	if ($v ne "") {
		my $sql = "UPDATE gallery_styles SET ".$v." ".
				  "WHERE ID=".$db->db_quote( $self->getID() )." ".
				  "LIMIT 1";
		
		my $dbz = $db->db_do( $sql );
	}
	
	$self->readStyle();
}

1;
