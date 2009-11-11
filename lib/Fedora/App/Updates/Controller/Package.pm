package Fedora::App::Updates::Controller::Package;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

Fedora::App::Updates::Controller::Package - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Fedora::App::Updates::Controller::Package in Package.');
}


=head1 AUTHOR

Chris Weyl

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;