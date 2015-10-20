package Beam::Wire::Moose;
# ABSTRACT: Dependency Injection with extra Moose features

use Moose;
use Moose::Meta::Class;
extends 'Beam::Wire';

around create_service => sub {
    my ( $orig, $self, $name, %service_info ) = @_;
    if ( my $roles = $service_info{with} ) {
        my @args = $self->parse_args( %service_info );
        my @roles = ref $roles eq 'ARRAY' ? @{$roles} : $roles;
        my $meta = Moose::Meta::Class->create_anon_class(
            superclasses => [ $service_info{class} ],
            roles        => \@roles,
            cache        => 1,
        );
        $service_info{class} = $meta->name;
    }
    return $self->$orig( $name, %service_info );
};

1;
__END__

=head1 SYNOPSIS

    # container.yml
    db:
        class: My::Database
        with:
            - My::Role::Cache
            - My::Role::Log
        args:
            dbh: { ref: dbh }
    dbh:
        class: DBI
        args:
            - 'dbi:sqlite:data.db'

=head1 DESCRIPTION

Beam::Wire::Moose is a subclass of Beam::Wire that adds support for Moose-specific
features.

=head1 SERVICE CONFIG

=head2 with

Compose roles into this object at run-time. This creates an anonymous class that
extends the C<class> config and consumes the roles defined by C<with>.

NOTE: This means the service is not an instance of C<class> but an instance of
a class that inherits from C<class>. Be cautious when using C<ref> and
C<Scalar::Util::blessed>.


=head1 SEE ALSO

=over 4

=item L<Beam::Wire>

=back

