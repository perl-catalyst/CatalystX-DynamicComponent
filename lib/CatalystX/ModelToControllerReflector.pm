package CatalystX::ModelToControllerReflector;
use Moose::Role;
use Moose::Util qw/does_role/;
use namespace::autoclean;

with 'CatalystX::DynamicComponent' => {
    name => '_setup_dynamic_controller',
    pre_immutable_hook => '_setup_dynamic_controller_meta',
};

requires 'setup_components';

after 'setup_components' => sub { shift->_setup_dynamic_controllers(@_); };

sub _setup_dynamic_controllers {
    my ($app) = @_;
    my @model_names = grep { /::Model::/ } keys %{ $app->components };
    
    foreach my $model_name (@model_names) {
        $app->_reflect_model_to_controller( $model_name, $app->components->{$model_name} );
    }
}

sub _reflect_model_to_controller {
    my ( $app, $model_name, $model ) = @_;

    my $class = blessed($app) || $app;

    my $controller_name = $model_name;
    $controller_name =~ s/::Model::/::Controller::/;

    my $suffix = $model_name;
    $suffix =~ s/^.*::Model:://;

    my %controller_methods;
    my $model_methods = $model->meta->get_method_map;
    foreach my $method_name (keys %$model_methods) {
            next unless does_role($model_methods->{$method_name}, 'CatalystX::ControllerGeneratingModel::DispatchableMethod');
            # Note need to pass model name, as the method actually comes from
            # the underlying model class, not the Catalyst shim class we autogenerated.
            $controller_methods{$method_name} = $app->generate_reflected_controller_action_method($suffix, $model_methods->{$method_name})
    }

    $app->_setup_dynamic_controller( $controller_name, {}, \%controller_methods );
}

sub _setup_dynamic_controller_meta {
    my ($app, $meta) = @_;
    # Wrong namespace, should be config
    # and we force it to do a role to
    # add our crap, allowing the user
    # to overlay functionality..
    $meta->superclasses($app . '::ControllerBase', $meta->superclasses);
}

sub generate_reflected_controller_action_method {
    my ( $app, $model, $method ) = @_;
    my $method_name = $method->name; # Is it worth passing the actual method object here?
    sub {
        my ($self, $c, @args) = @_;
        $c->res->header('X-From-Model', $model);
        $c->res->header('X-From-Model-Data', $c->model($model)->$method_name(@args));
        $c->res->body('OK');
    };
}

1;

