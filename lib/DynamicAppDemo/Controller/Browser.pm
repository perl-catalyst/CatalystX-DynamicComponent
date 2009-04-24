package DynamicAppDemo::Controller::Browser;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub root : Chained('/root') PathPart('') CaptureArgs() {}

sub list : Chained('root') PathPart('') Args(0) ActionClass('REST') {}

sub list_GET {
    my ($self, $c) = @_;
    $c->stash->{rest} = $c->model('DynamicControllerIntrospection')->list_controllers;
}

__PACKAGE__->meta->make_immutable;

