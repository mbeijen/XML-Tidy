#!/usr/bin/perl -w
# 4C3HOH1 - XML::Tidy.pm created by Pip Stuart <Pip@CPAN.Org>
#   to tidy XML documents as parsed XML::XPath objects.

=head1 NAME

XML::Tidy - tidy indenting of XML documents

=head1 VERSION

This documentation refers to version 1.0.4CAJna1 of 
XML::Tidy, which was released on Fri Dec 10 19:49:36:01 2004.

=head1 SYNOPSIS

  use XML::Tidy;

  # create new   XML::Tidy object from         MainFile.xml
  my $tidy_obj = XML::Tidy->new('filename' => 'MainFile.xml');

  # Tidy up the indenting
     $tidy_obj->tidy();

  # Write out changes back to MainFile.xml
     $tidy_obj->write();

=head1 DESCRIPTION

This module creates XML document objects (with inheritance from
L<XML::XPath>) to tidy mixed-content (ie. non-data) text node
indenting.

=head1 2DO

=over 2

=item - mk tidy keep doc order when duping attz, namespaces,
          (hopefully someday PIs) into temp $docu && $tnod

=item -     What else does Tidy need?

=back

=head1 USAGE

=head2 new()

This is the standard Tidy object constructor.  It can take
the same parameters as an L<XML::XPath> object constructor to
initialize the XML document object.  These can be any one of:

  'filename' => 'SomeFile.xml'
  'xml'      => $variable_which_holds_a_bunch_of_XML_data
  'ioref'    => $file_InputOutput_reference
  'context'  => $existing_node_at_specified_context_to_become_new_obj

=head2 reload()

The reload() member function causes the latest data contained in
a Tidy object to be re-parsed which re-indexes all nodes.
This can be necessary after modifications have been made to nodes
which impact the tree node hierarchy because L<XML::XPath>'s find()
member preserves state info which can get out-of-sync.  reload() is
probably rarely useful by itself but it is needed by strip() &&
prune() so it is exposed as a method in case it comes in handy for
other uses.

=head2 strip()

The strip() member function searches the Tidy object for all
mixed-content (ie. non-data) text nodes && empties them out.
This will basically unformat any markup indenting.  strip() is
probably barely useful by itself but it is needed by tidy() &&
is exposed as a method in case it comes in handy for other uses.
It does make XML files smaller (sometimes significantly so) if
you don't care about human readability.

=head2 tidy()

The tidy() member function can take a single optional parameter as
the string that should be inserted for each indent level.  Some
examples:

  # Tidy up indenting with default two  (2) spaces per indent level
     $tidy_obj->tidy();

  # Tidy up indenting with         one  (1) space  per indent level
     $tidy_obj->tidy(' ');

  # Tidy up indenting with         four (4) spaces per indent level
     $tidy_obj->tidy('    ');

  # Tidy up indenting with         one  (1) tab    per indent level
     $tidy_obj->tidy("\t");

  # Tidy up indenting with         two  (2) tabs   per indent level
     $tidy_obj->tidy("\t\t");

  # Ruin KAKA indenting with some KAKA non-whitespace string!  KAKA!
     $tidy_obj->tidy("KA"); # this does damage so backup XML first

The default behavior is to use two (2) spaces (ie. '  ') for each
indent level.  The Tidy object gets all mixed-content (ie. non-data)
text nodes reformatted to appropriate indent levels according to tree
nesting depth.

NOTE: There seems to be a bug in L<XML::XPath> which does not allow
finding XML processing instructions (PIs) properly so they have been
commented out of tidy().  This means that tidy() unfortunately
removes processing instructions from files it operates on.  I hope
this shortcoming can be repaired in the near future.  tidy() also
disturbs some XML escapes in whatever ways L<XML::XPath> does.

=head2 prune()

The prune() member function takes an XPath location to remove (along
with all attributes && child nodes) from the Tidy object.  For
example, to remove all comments:

  $tidy_obj->prune('//comment()');

or to remove the third baz (XPath indexing is 1-based):

  $tidy_obj->prune('/foo/bar/baz[3]');

Pruning your XML tree is a form of tidying too so it snuck in here. =)
It seems L<XML::XPath> objects are dramatically more useful when they
all have access to this class of additional member functions.

=head2 write()

The write() member function can take an optional filename parameter
to write out any changes to the Tidy object.  If no parameters
are given, write() overwrites the original XML document file (if
a 'filename' parameter was given to the constructor).

write() will croak() if no filename can be found to write to.

write() can also take a secondary parameter which specifies an XPath
location to be written out as the new root element instead of the
Tidy object's root.  Only the first matching element is written.

=head1 CHANGES

Revision history for Perl extension XML::Tidy:

=over 4

=item - 1.0.4CAJna1  Fri Dec 10 19:49:36:01 2004

* added optional 'filename' => to write()

=item - 1.0.4CAAf5B  Fri Dec 10 10:41:05:11 2004

* removed 2nd param from tidy() so that 1st param is just indent string

* fixed pod errors

=item - 1.0.4C9JpoP  Thu Dec  9 19:51:50:25 2004

* added xplc option to write()

* added prune()

=item - 1.0.4C8K1Ah  Wed Dec  8 20:01:10:43 2004

* inherited from XPath so that those methods can be called directly

* original version (separating Tidy.pm from Merge.pm)

=back

=head1 INSTALL

From the command shell, please run:

    `perl -MCPAN -e "install XML::Tidy"`

or uncompress the package && run the standard:

    `perl Makefile.PL; make; make test; make install`

=head1 FILES

XML::Tidy requires:

L<Carp>                to allow errors to croak() from calling sub

L<XML::XPath>          to use XPath statements to query && update XML

L<XML::XPath::XMLParser> to parse XML documents into XPath objects

=head1 LICENSE

Most source code should be Free!
  Code I have lawful authority over is && shall be!
Copyright: (c) 2004, Pip Stuart.
Copyleft : This software is licensed under the GNU General Public
  License (version 2), && as such comes with NO WARRANTY.  Please
  consult the Free Software Foundation (http://FSF.Org) for
  important information about your freedom.

=head1 AUTHOR

Pip Stuart <Pip@CPAN.Org>

=cut

package XML::Tidy;
use warnings;
use strict;
require      XML::XPath;
use base qw( XML::XPath );
use Carp;
use XML::XPath::XMLParser;
our $VERSION     = '1.0.4CAJna1'; # major . minor . PipTimeStamp
our $PTVR        = $VERSION; $PTVR =~ s/^\d+\.\d+\.//; # strip major and minor
# Please see `perldoc Time::PT` for an explanation of $PTVR

my $DBUG = 0;

my $xmlh = qq(<?xml version="1.0" encoding="utf-8"?>\n); # standard XML header

sub new {
  my $clas = shift();
  my $xpob = XML::XPath->new(@_);
  my $self = bless($xpob, $clas);
  #   self just a new XPath obj blessed into Tidy class
  return($self);
}

sub reload { # dump XML text && re-parse object to re-index all nodes cleanly
  my $self = shift();
  if(defined($self)) {
    my($root)= $self->findnodes('/');
    my $data = $xmlh;
    $data .= $_->toString() foreach($root->getChildNodes());
    $self->set_xml($data);
    my $prsr = XML::XPath::XMLParser->new('xml' => $data);
    $self->set_context($prsr->parse());
  }
}

sub strip { # strips out all text nodes from any mixed content
  my $self = shift();
  if(defined($self)) {
    my @nodz = $self->findnodes('//*');
    foreach(@nodz) {
      if($_->getNodeType() eq XML::XPath::Node::ELEMENT_NODE) {
        my @kidz = $_->getChildNodes();
        foreach my $kidd (@kidz) {
          if($kidd->getNodeType() eq XML::XPath::Node::TEXT_NODE &&
             @kidz > 1 && $kidd->getValue() =~ /^\s*$/) {
            $kidd->setValue(''); # empty them all out
          }
        }
      }
    }
    $self->reload(); # reload all XML as text to re-index nodes
  }
}

# tidy XML indenting with a certain indent string
sub tidy {
  my $self = shift(); my $ndnt = shift() || '  ';
  $ndnt = "\t" if($ndnt =~ /tab/i ); # allow some indent_type descriptions
  $ndnt = '  ' if($ndnt =~ /spac/i);
  $self->strip(); # strips all object's text nodes from mixed content
  # now insert new nodes with newlines && indenting by tree nesting depth
  my $dpth = 0; # keep track of element nest depth
  my $docu = XML::XPath::Node::Element->new(); # temporary document root node
  if(defined($self)) {
    # NOTE: There's a bug in XML::XPath that doesn't let you find PIs! =(
    foreach(#$self->findnodes('processing-instruction()'),
            $self->findnodes('comment()')) {
      print "NodeType:" . $_->getNodeType() . " = " . $_->toString() .
             "\n  pos:" . $_->get_pos() .
           " Glob_pos:" . $_->get_global_pos() . "\n" if($DBUG);
      $docu->appendChild($_); # consider insertBefore($posi) to keep order
    }
    my($root)= $self->findnodes('/*');
    print "RT  Found new      elem:" . $root->getName() . "\n" if($DBUG);
    if($root->getChildNodes()) { # recursively tidy children
      $root = $self->_rectidy($root, ($dpth + 1), $ndnt);
    }
    $docu->appendChild($root);
    ($root)= $docu->findnodes('/');
    my $data = $xmlh;
    $data .= $_->toString() foreach($root->getChildNodes());
    $self->set_xml($data);
    my $prsr = XML::XPath::XMLParser->new('xml' => $data);
    $self->set_context($prsr->parse());
  }
}

sub _rectidy { # recursively tidy up indent formatting of elements
  my $self = shift(); my $node = shift();
  my $dpth = shift(); my $ndnt = shift();
  my $tnod = undef; # temporary node which will get nodes surrounding children
  $tnod = XML::XPath::Node::Element->new($node->getName());
  foreach($node->findnodes('@*')) { # copy all attributes
    print "NR  Found new      attr:" . $_->getName() . "\n" if($DBUG);
    $tnod->appendAttribute($_);
  }
  foreach($node->getNamespaces()) { # copy all namespaces
    print "NR  Found new namespace:" . $_->toString() .
                          "\n  pos:" . $_->get_pos() .
                        " Glob_pos:" . $_->get_global_pos() . "\n" if($DBUG);
    $tnod->appendNamespace($_);
  }
  my @kidz = $node->getChildNodes(); my $lkid;
  foreach my $kidd (@kidz) {
    if($kidd->getNodeType() ne XML::XPath::Node::TEXT_NODE && (!$lkid ||
       $lkid->getNodeType() ne XML::XPath::Node::TEXT_NODE)) {
      $tnod->appendChild(XML::XPath::Node::Text->new("\n" . ($ndnt x $dpth)));
    }
    if($kidd->getNodeType() eq XML::XPath::Node::ELEMENT_NODE) {
      print "NR  Found new      elem:" . $kidd->getName() . " dpth:$dpth\n" if($DBUG);
      my @gkdz = $kidd->getChildNodes();
      if(@gkdz    && ($gkdz[0]->getNodeType() ne XML::XPath::Node::TEXT_NODE ||
        (@gkdz > 1 && $gkdz[1]->getNodeType() ne XML::XPath::Node::TEXT_NODE))) {
        $kidd = $self->_rectidy($kidd, ($dpth + 1), $ndnt); # recursively tidy
      }
    }
    $tnod->appendChild($kidd);
    $lkid = $kidd;
  }
  $tnod->appendChild(XML::XPath::Node::Text->new("\n" . ($ndnt x ($dpth - 1))));
  return($tnod);
}

sub prune { # remove a section of the tree at the xpath location parameter
  my $self = shift(); my $xplc = shift() || return(); # can't prune root node
  if(defined($self) && defined($xplc) && length($xplc) && $xplc ne '/') {
    $self->reload(); # update all nodes && internal XPath indexing before find
    foreach($self->findnodes($xplc)) {
      print "Pruning:$xplc\n" if($DBUG);
      my $prnt = $_->getParentNode();
      $prnt->removeChild($_) if(defined($prnt));
    }
  }
}

sub write { # write out an XML file to disk from a Tidy object
  my $self = shift(); my $root;
  my $flnm = shift() || $self->get_filename();
  if(defined($flnm) && $flnm && $flnm =~ /^[-_]?(flnm|filename)$/) {
     $flnm = shift() || $self->get_filename();
  }
  my $xplc = shift() || undef;
  if(defined($xplc) && $xplc && $xplc =~ /^[-_]?(xplc$|xpath_loc)/) {
     $xplc = shift() || undef;
  }
  if(defined($self) && defined($flnm)) {
    if(defined($xplc) && $xplc) {
         $root = XML::XPath::Node::Element->new();
      my($rtnd)= $self->findnodes($xplc);
         $root->appendChild($rtnd);
    } else {
        ($root)= $self->findnodes('/');
    }
    my @kids = $root->getChildNodes();
    open( FILE, ">$flnm");
    print FILE $xmlh;
    print FILE $_->toString() , "\n" foreach(@kids);
    close(FILE);
  } else {
    croak("!*EROR*! No filename could be found to write() to!\n");
  }
}

127;
