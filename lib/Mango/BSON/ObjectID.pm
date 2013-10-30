package Mango::BSON::ObjectID;
use Mojo::Base -base;
use overload '""' => sub { shift->to_string }, fallback => 1;

use Carp 'croak';
use Mojo::Util 'md5_bytes';
use Sys::Hostname 'hostname';

# 3 byte machine identifier
my $MACHINE = substr md5_bytes(hostname), 0, 3;

# Global counter
my $COUNTER = 0;

sub new {
  my ($class, $oid) = @_;
  croak qq{Invalid object id "$oid"}
    if defined $oid && $oid !~ /^[0-9a-fA-F]{24}$/;
  return defined $oid ? $class->SUPER::new(oid => $oid) : $class->SUPER::new;
}

sub from_epoch {
  my ($self, $epoch) = @_;
  $self->{oid} = _generate($epoch);
  return $self;
}

sub to_epoch { unpack 'N', substr(pack('H*', shift->to_string), 0, 4) }

sub to_string { shift->{oid} //= _generate() }

sub _generate {

  # 4 byte time, 3 byte machine identifier and 2 byte process id
  my $oid = pack('N', shift // time) . $MACHINE . pack('n', $$ % 0xffff);

  # 3 byte counter
  $COUNTER = ($COUNTER + 1) % 0xffffff;
  return unpack 'H*', $oid . substr(pack('V', $COUNTER), 0, 3);
}

1;

=encoding utf8

=head1 NAME

Mango::BSON::ObjectID - Object ID type

=head1 SYNOPSIS

  use Mango::BSON::ObjectID;

  my $oid = Mango::BSON::ObjectID->new('1a2b3c4e5f60718293a4b5c6');
  say $oid->to_epoch;

=head1 DESCRIPTION

L<Mango::BSON::ObjectID> is a container for the BSON object id type used by
L<Mango::BSON>.

=head1 METHODS

L<Mango::BSON::ObjectID> inherits all methods from L<Mojo::Base> and
implements the following new ones.

=head2 new

  my $oid = Mango::BSON::ObjectID->new;
  my $oid = Mango::BSON::ObjectID->new('1a2b3c4e5f60718293a4b5c6');

Construct a new L<Mango::BSON::ObjectID> object.

=head2 from_epoch

  my $oid = $oid->from_epoch(1359840145);

Generate new object id with specific epoch time.

=head2 to_epoch

  my $epoch = $oid->to_epoch;

Extract epoch seconds from object id.

=head2 to_string

  my $str = $oid->to_string;
  my $str = "$oid";

Stringify object id.

=head1 SEE ALSO

L<Mango>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
