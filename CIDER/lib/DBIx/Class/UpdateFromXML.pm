package DBIx::Class::UpdateFromXML;

use strict;
use warnings;

use base 'DBIx::Class';
use XML::LibXML;
use String::CamelCase qw( camelize );
use DateTime::Format::ISO8601;

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

    my @children = $element->getChildrenByTagName( '*' );
    return $class->xml_elements_to_hashref( @children );
}

=head2 xml_elements_to_hashref( @elements )

Converts a list of XML::LibXML::Elements to a hashref whose keys are
the tagNames of the elements.  Each value is either an arrayref of
child elements of that element, or a string if the element only has
text content, or undef if the element is empty.

For example, given ( <bar>Blah</bar>, <baz><garply/></baz> ),
it would return { bar => "Blah", baz => [ <garply/> ] }.

=cut

sub xml_elements_to_hashref {
    my $class = shift;

    my $hashref = { };
    for my $elt ( @_ ) {
        my @children = $elt->getChildrenByTagName( '*' );
        if ( !@children ) {
            $hashref->{ $elt->tagName } = $elt->textContent || undef;
        }
        else {
            $hashref->{ $elt->tagName } = [ @children ];
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

=head2 update_boolean_from_xml_hashref( $hr, $colname [, $tag] )

Update a boolean column from an XML element hashref.  $tag (which
defaults to $colname converted to mixed case) is the tagname of the
child element containing the boolean value.  'false' and '0' are
considered false; an empty element is considered null; everything else
is considered true.

=cut

sub update_boolean_from_xml_hashref {
    my $self = shift;
    my ( $hr, $colname, $tag ) = @_;

    $tag ||= lcfirst( camelize( $colname ) );
    if ( exists $hr->{ $tag } ) {
        my $val = $hr->{ $tag };
        if ( defined $val ) {
            if ( $val eq 'false' || $val eq '0' ) {
                $self->$colname( 0 );
            }
            else {
                $self->$colname( 1 );
            }
        }
        else {
            $self->$colname( undef );
        }
    }
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

=head2 update_cv_from_xml_hashref( $hr, $colname [, $ident [, $tag]])

Update a controlled vocabulary column from an XML element hashref.
$tag (which defaults to $colname converted to mixed case) is the
tagname of the child element whose text content is part of the
controlled vocabulary.  $ident (which defaults to 'name') is the name
of the text identifier field in the controlled vocabulary object.

=cut

sub update_cv_from_xml_hashref {
    my $self = shift;
    my ( $hr, $colname, $ident, $tag ) = @_;

    $ident ||= 'name';
    $tag ||= lcfirst( camelize( $colname ) );

    if ( exists( $hr->{ $tag } ) ) {
        my $rs = $self->result_source->related_source( $colname )->resultset;
        my $obj = $rs->find( { $ident => $hr->{ $tag } } );
        $self->set_inflated_column( $colname => $obj );
    }
}

# TO DO: refactor the above & below methods

=head2 update_term_from_xml_hashref( $hr, $colname [, $ident [, $tag]])

Update an authority term column from an XML element hashref.  $tag
(which defaults to $colname converted to mixed case) is the tagname of
the child element whose text content is the authority term.  $ident
(which defaults to 'name') is the name of the text field in the
authority term object.  The term will be added to the authority list
if it doesn't already exist.

=cut

sub update_term_from_xml_hashref {
    my $self = shift;
    my ( $hr, $colname, $ident, $tag ) = @_;

    $ident ||= 'name';
    $tag ||= lcfirst( camelize( $colname ) );

    if ( exists( $hr->{ $tag } ) ) {
        my $rs = $self->result_source->related_source( $colname )->resultset;
        my $obj = $rs->find_or_create( { $ident => $hr->{ $tag } } );
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

=head2 update_relationships_from_xml_hashref( $hr )

Update a Relationship relationship from an XML element hashref.  The
tagname of the child element is 'relationships'; it has a 'predicate'
attribute and a 'pid' child element.  The table name is used to form
the relationship name, e.g. 'collection_relationships'.

=cut

sub update_relationships_from_xml_hashref {
    my $self = shift;
    my ( $hr ) = @_;

    if ( exists( $hr->{ relationships } ) ) {
        my $relname = $self->table . '_relationships';
        $self->delete_related( $relname );
        my $schema = $self->result_source->schema;
        my $rs = $schema->resultset( 'RelationshipPredicate' );
        for my $rel ( @{ $hr->{ relationships } } ) {
            my $pred = $rs->find(
                { predicate => $rel->getAttribute( 'predicate' ) } );
            my $pid = ( $rel->getChildrenByTagName( '*' ) )[0]->textContent;
            $self->create_related( $relname,
                                   { predicate => $pred, pid => $pid } );
        }
    }
}

=head2 update_audit_trail_from_xml_hashref( $hr )

Update the audit trail from an XML element hashref.  Each log
timestamp may be a date, which is converted to a date/time by setting
the time to 12am.

This should be called after the object has been updated, so that the
imported audit trail overrides the logs from that update.

=cut

sub update_audit_trail_from_xml_hashref {
    my $self = shift;
    my ( $hr ) = @_;

    if ( exists( $hr->{ auditTrail } ) ) {
        my $trail = $self->audit_trail;
        $trail->logs->delete;
        for my $log_elt ( @{ $hr->{ auditTrail } } ) {
            my $log_hr = $self->xml_to_hashref( $log_elt );

            my $ts = $log_hr->{ timestamp };
            $ts = DateTime::Format::ISO8601->parse_datetime( $ts );

            my $staff_hr = $self->xml_elements_to_hashref(
                @{ $log_hr->{ staff } } );
            my $staff_rs = $self->result_source->schema->resultset( 'Staff' );
            my $staff = $staff_rs->find_or_create( {
                first_name => $staff_hr->{ firstName },
                last_name  => $staff_hr->{ lastName }
            } );

            $trail->add_to_logs( { action => $log_elt->tagName,
                                   timestamp => $ts,
                                   staff => $staff, } );
        }
    }
}

=head1 LICENSE

Copyright 2012 Tufts University

CIDER is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.

CIDER is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public
License along with CIDER.  If not, see
<http://www.gnu.org/licenses/>.

=cut

1;
