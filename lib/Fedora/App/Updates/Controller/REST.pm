package Fedora::App::Updates::Controller::REST;

use Moose;
use namespace::autoclean;
use CatalystX::Alt::Routes;

BEGIN { extends  'Catalyst::Controller::REST' }
with 'Fedora::App::Updates::ControllerRole::REST';

# debugging...
#use Smart::Comments '###';

##############################################################
# Actions

#sub package_names : Local ActionClass('REST') { }

public package_names => rest { };

sub package_names_GET {
    my ($self, $c) = @_;

    my $like = $c->req->params->{name} || '%';
    $like =~ s/\*/%/g;

    my $rs = $c->model('Updates::Packages');
    my @names = $rs
        ->search(
            { name => { like => $like }         },
            { distinct => 1, order_by => 'name' },
        )
        ->get_column('name')
        ->all
        ;

    if (my $range = $c->req->header('Range')) {

        my $total = @names;
        $range =~ s/items=//;
        my ($from, $to) = split /-/, $range;
        # we do sometimes see 'items=0-'
        warn "to: $to";
        $to = $total - 1 unless $to && $to < $total;

        my @partial = @names[$from..$to];

        # make sure $to = $from + actual number of items
        $to = $from + scalar @partial;

        my @items = map { { name => $_, label => $_ } } @partial;

        $c->res->header('Content-Range' => "items $from-$to/$total");
        #return $self->status_partial_content($c, entity => \@partial);
        #return $self->status_partial_content($c, entity => { label => 'name', identifier => 'name', items => \@items});
        return $self->status_partial_content($c, entity => \@items);
    }

    @names = map { { name => $_, label => $_ } } @names;
    $self->status_ok($c, entity => \@names);
}


sub packages : Local ActionClass('REST') { }

sub packages_GET {
    my ($self, $c) = @_;

    # FIXME need search bits here
    #my $search = $self->query_to_dbic($c);
    #my $rs = $c->model('Updates::Packages')->search($search, { order_by => 'me.name' });
    my $rs = $c->model('Updates::Packages')->search($self->query_to_dbic($c));
    my $transform_sub = sub { shift->all_versions };

    return $self->handle_partial_request($c, $rs, $transform_sub)
        if $c->req->header('Range');

    return $self->status_ok($c, entity => $transform_sub->($rs));
}

sub query_to_dbic {
    my ($self, $c) = @_;

    # FIXME this needs refactoring... ew
    #my %legal = map { $_ => 1 } qw{ name owner };
    my %legal = (owner => 'owner_id', name => 'name');
    my $params = $c->req->parameters;

    ### $params

    my ($search, $attrs) = ({}, { order_by => 'me.name' });

    PARAM_LOOP:
    for my $param (keys %$params) {

        if ($legal{$param}) {

            # if we're a wildcard search...
            my $value = $params->{$param};
            $value =~ s/\*/%/g;
            $search->{"me.$legal{$param}"} = $value =~ /%/ ? { LIKE => $value } : $value;
            next PARAM_LOOP;
        }

        next PARAM_LOOP unless $param =~ /^sort\(/;

        # so, get our sort name and ASC/DESC
        $param =~ s/^sort\(//;
        $param =~ s/\)$//;

        my $order = $param =~ /^-/ ? '-desc' : '-asc';
        warn $param;
        $param =~ s/^(-| )//;
        warn $param;
        next PARAM_LOOP unless $legal{$param};
        $attrs->{order_by} = { $order => "me.$legal{$param}" };
    }

    ### $search
    ### $attrs

    return ($search, $attrs);

    my $name  = $c->req->parameters->{name};
    my $owner = $c->req->parameters->{owner};

    my ($search, $atts) = ({}, {});

    if ($name =~ /\*/) {

        # if we're a wildcard search...
        $name =~ s/\*/%/g;
        $search->{'me.name'} = { LIKE => $name };
    }
    elsif ($name) { $search->{'me.name'} = $name }

    if ($owner =~ /\*/) {

        # if we're a wildcard search...
        $owner =~ s/\*/%/g;
        $search->{'me.owner_id'} = { LIKE => $owner };
    }
    elsif ($owner) { $search->{'me.owner_id'} = $owner }

    return $search;
}



__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

Fedora::App::Updates::Controller::REST - Catalyst Controller

=head1 DESCRIPTION

RESTful Catalyst Controller.

=head1 HELPERS

=head2 status_partial_content

Returns a "206 Partial Content" response.  Takes an "entity" to serialize.

Dojo uses this for requesting chunks of information.

Example:

  $self->status_partial_content(
     $c,
     entity => { ... },
  );

=head2 _explode

Take a L<DBIx::Class::ResultSet> and "explode" it out into a collection of
hashrefs, using L<DBIx::Class::ResultClass::HashRefInflator>.

=head1 PATH ACTIONS

=head2 package_names


=head2 packages


=head1 AUTHOR

Chris Weyl <cweyl@alumni.drew.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2008, Chris Weyl <cweyl@alumni.drew.edu>

This library is free software; you can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License as published by the Free
Software Foundation; either version 2.1 of the License, or (at your option)
any later version.

This library is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
OR A PARTICULAR PURPOSE.

See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this library; if not, write to the

    Free Software Foundation, Inc.,
    59 Temple Place, Suite 330,
    Boston, MA  02111-1307 USA

=cut
