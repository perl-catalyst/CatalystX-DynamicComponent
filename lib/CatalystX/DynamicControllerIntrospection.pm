package CatalystX::Dynamic::ControllerIntrospection;
use Moose;
use MooseX::Types::Moose qw/ArrayRef/;
use namespace::autoclean;

# SYNOPSIS: Provide catalyst controller introspection as a model.

for my $name (qw/ classes roles /) {

    has "limit_to_$name" => ( 
        isa => ArrayRef, is => 'ro', default => sub { [] }, 
        predicate => "_should_limit_to_$name",
    );

}

sub list_controllers {
    my ($self, $app) = @_;
    my @controllers = grep { 1 } $app->controllers;
}

__PACKAGE__->meta->make_immutable;

