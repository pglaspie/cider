package DBIx::Class::UpdateFromXML;

use strict;
use warnings;

use base 'DBIx::Class';
use XML::LibXML;
use String::CamelCase qw( camelize );

=head2 xml_to_hashref( $element )

Converts an XML::LibXML::Element to a hashref whose keys are the
tagNames of the child elements.  Each value is either an arrayref of
child elements of that child, or a string if the child only has text
content, or undef if the child is empty.

For example, given <foo><bar>Blah</bar><baz><garply/></baz></foo>,
it would return { bar => "Blah", baz => [ <garply/> ] }.

=cut

sub xml_to_hashref {
    my $class = shift;
    my ( $element ) = @_;

    my $hashref = { };
    for my $child ( $element->getChildrenByTagName( '*' ) ) {
        my @grandchildren = $child->nonBlankChildNodes;
        if ( !@grandchildren ) {
            $hashref->{ $child->tagName } = undef;
        }
        elsif ( $grandchildren[0]->nodeType == XML_TEXT_NODE ) {
            $hashref->{ $child->tagName } = $child->textContent;
        }
        else {
            $hashref->{ $child->tagName } = [ @grandchildren ];
        }
    }
    return $hashref;
}

=head2 update_text_from_xml_hashref( $hr, $colname [, $tag] )

Update a text column from an XML element hashref.  $tag (which
defaults to $colname converted to mixed case) is the tagname of the
child element containing the text value.

=cut

sub update_text_from_xml_hashref {
    my $self = shift;
    my ( $hr, $colname, $tag ) = @_;

    $tag ||= lcfirst( camelize( $colname ) );

    $self->$colname( $hr->{ $tag } ) if exists $hr->{ $tag };
}

=head2 update_dates_from_xml_hashref( $hr, $colname [, $tag] )

Update a pair of date columns, ${colname}_from and ${colname}_to, from
an XML element hashref.  $tag (which defaults to $colname converted to
mixed case) is the tagname of the child element containing the
date(s).

=cut

sub update_dates_from_xml_hashref {
    my $self = shift;
    my ( $hr, $colname, $tag ) = @_;

    my $from = "${colname}_from";
    my $to   = "${colname}_to";
    $tag ||= lcfirst( camelize( $colname ) );

    if ( exists( $hr->{ $tag } ) ) {
        my $date = $hr->{ $tag };
        if ( ref $date ) {
            $self->$from( $date->[0]->textContent );
            $self->$to  ( $date->[1]->textContent );
        }
        else {
            $self->$from( $date );
            $self->$to  ( undef );
        }
    }
}

=head2 update_cv_from_xml_hashref( $hr, $colname, $ident [, $tag] )

Update a controlled vocabulary column from an XML element hashref.
$tag (which defaults to $colname converted to mixed case) is the
tagname of the child element whose text content is part of the
controlled vocabulary.  $ident is the name of the text identifier
field in the controlled vocabulary object.

=cut

sub update_cv_from_xml_hashref {
    my $self = shift;
    my ( $hr, $colname, $ident, $tag ) = @_;

    $tag ||= lcfirst( camelize( $colname ) );

    if ( exists( $hr->{ $tag } ) ) {
        my $rs = $self->result_source->related_source( $colname )->resultset;
        my $obj = $rs->find( { $ident => $hr->{ $tag } } );
        $self->set_inflated_column( $colname => $obj );
    }
}

=head2 update_has_many_from_xml_hashref( $hr, $relname, $ident [, $tag] )

Update a has_many relationship from an XML element hashref.  $tag
(which defaults to $relname converted to mixed case) is the tagname of
the child element whose child elements have text content, which will
become objects of the related class.  $proxy is the name of the text
field on the related class.

For example, if $hr comes from the following XML element:

<collection>
  <associatedMaterial>
    <material>Pamphlet</material>
    <material>Brochure</material>
  </associatedMaterial>
<collection>

then the following will set $collection->material to be two
CollectionMaterial objects whose material columns are "Pamphlet" and
"Brochure":

$collection->update_has_many_from_xml_hashref(
  $hr, material => 'material', 'associatedMaterial' );

=cut

sub update_has_many_from_xml_hashref {
    my $self = shift;
    my ( $hr, $relname, $proxy, $tag ) = @_;

    $tag ||= lcfirst( camelize( $relname ) );
    if ( exists( $hr->{ $tag } ) ) {
        $self->delete_related( $relname );
        $self->create_related( $relname, { $proxy => $_->textContent } )
            for @{ $hr->{ $tag } };
    }
}

1;
