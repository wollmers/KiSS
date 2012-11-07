package Kiss::Content;

use strict;
use warnings;

use v5.10.1;

use lib '/home/helmut/MYDLjE/per/lib';

use Mojo::DOM;
#use Template::Semantic;
#use HTML::TreeBuilder;
#use HTML::TreeBuilder::XPath;

use Data::Dumper;

sub new {
    my $class = shift;
    
    my $self = {};
    bless $self, $class;
    return $self;
}

sub get_page_path {
  my $self = shift;
  
  my $path = $ENV{'REQUEST_URI'};
  my $pages = $ENV{'DOCUMENT_ROOT'} . '/pages/';

  my $page = $pages . $path;
  if ( $path =~ m/\/$/ ) {  
    $page .= 'index.html';    
  }
  else {
    $page .= '.html';
  }
  print STDERR '$page: ',$page,"\n";

  if (! -e $page) {
    $page = $pages . 'index.html';    
  }
  return $page;
}

sub get_html {
  my $self = shift;
     
  my $page = $self->get_page_path();
      
  my $encoding = 'utf-8';
  open(my $fh, "<:encoding($encoding)", $page) or print STDERR "failed opening $page \n";
  my $content = '';
  while (my $line = <$fh>) {
    $content .= $line;
  }
  close($fh);
  
  #print STDERR '$content: ',Dumper($content),"\n";
  my $html = '';
  
=comment
  
  if ($content =~ m/^\s*_[{]\s*temp:\s*([^}]+)\s*[}]_/x) {
    print STDERR '$content matches temp: '.$1,"\n";
    my $template = $1;
    $html .= $self->render_template($content,$1);  
  }
  else {
    $html .= $content;
  }
  
=cut

  $html .= $self->render_semantic($content);

  return $html;
}

sub render_template {
  my $self = shift;
  my $content = shift;
  my $template = shift;
  
  $content =~ s/^\s*_[{]\s*temp:\s*([^}]+)\s*[}]_//;
  $template = $ENV{'DOCUMENT_ROOT'} . '/templates/' . $template;
  
  my $html = '';
  
  if ( -e $template ) {
    my $encoding = 'utf-8';
    local $\;

    open(my $fh, "<:encoding($encoding)", $template) or print STDERR "failed opening $template \n";
    while (my $line = <$fh>) {
    $html .= $line;
    }
    $html =~ s/_[{]content[}]_/$content/g;    
  }
  return $html;
}

sub render_semantic {
  my $self = shift;
  my $content = shift;
  
  my $templates = $ENV{'DOCUMENT_ROOT'} . '/templates/';
  
  my $page_dom = Mojo::DOM->new($content);
  
  my $wrapper = $page_dom->at('html')->attrs('wrapper');
  say STDERR '$wrapper: ',$wrapper;
  my $encoding = 'utf-8';
  open(my $fh, "<:encoding($encoding)", "$templates$wrapper") or print STDERR "failed opening $wrapper \n";
  my $w_content = '';
  while (my $line = <$fh>) {
    $w_content .= $line;
  }
  close($fh);
    
  my $wrapper_dom = Mojo::DOM->new($w_content);
  
  
  my $html = '';
  
  #$html = $wrapper_dom->at('body')->replace_content($page_content);
  $wrapper_dom->at('div[id="page"]')->replace_content(
    $page_dom->at('div[id="page"]')->content_xml()
  )->root()->content_xml();
  
  open(my $hfh, "<:encoding($encoding)", $templates."header_common.html") or print STDERR "failed opening $wrapper \n";
  my $h_content = '';
  while (my $line = <$hfh>) {
    $h_content .= $line;
  }
  close($hfh);
    
  my $header_dom = Mojo::DOM->new($h_content);
  say STDERR $header_dom->at('head')->content_xml();
  $html = $wrapper_dom->at('head')->replace_content(
    $header_dom->at('head')->content_xml()
  )->root()->content_xml();
  
  
  return $html;

}

=comment

  use HTML::TreeBuilder::XPath;
  my $tree= HTML::TreeBuilder::XPath->new;
  $tree->parse_file( "mypage.html");
  my $nb=$tree->findvalue( '/html/body//p[@class="section_title"]/span[@class="nb"]');
  my $id=$tree->findvalue( '/html/body//p[@class="section_title"]/@id');

  my $p= $html->findnodes( '//p[@id="toto"]')->[0];

findnodes_as_strings ($path)

Returns a list of the values of the result nodes.

=cut

1;

