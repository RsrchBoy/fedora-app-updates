package Fedora::App::Updates::Schema::Result::Versions;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

Fedora::App::Updates::Schema::Result::Versions

=cut

__PACKAGE__->table("versions");

=head1 ACCESSORS

=head2 dist_id

  data_type: INT
  default_value: undef
  is_nullable: 0
  size: 11

=head2 package_id

  data_type: INT
  default_value: undef
  is_nullable: 0
  size: 11

=head2 ga_version

  data_type: VARCHAR
  default_value: undef
  is_nullable: 1
  size: 16

=head2 ga_release

  data_type: VARCHAR
  default_value: undef
  is_nullable: 1
  size: 16

=head2 ga_build_id

  data_type: INT
  default_value: undef
  is_nullable: 1
  size: 11

=head2 updates_version

  data_type: VARCHAR
  default_value: undef
  is_nullable: 1
  size: 16

=head2 updates_release

  data_type: VARCHAR
  default_value: undef
  is_nullable: 1
  size: 16

=head2 updates_build_id

  data_type: INT
  default_value: undef
  is_nullable: 1
  size: 11

=head2 testing_version

  data_type: VARCHAR
  default_value: undef
  is_nullable: 1
  size: 16

=head2 testing_release

  data_type: VARCHAR
  default_value: undef
  is_nullable: 1
  size: 16

=head2 testing_build_id

  data_type: INT
  default_value: undef
  is_nullable: 1
  size: 11

=head2 candidates_version

  data_type: VARCHAR
  default_value: undef
  is_nullable: 1
  size: 16

=head2 candidates_release

  data_type: VARCHAR
  default_value: undef
  is_nullable: 1
  size: 16

=head2 candidates_build_id

  data_type: INT
  default_value: undef
  is_nullable: 1
  size: 11

=head2 stamp

  data_type: TIMESTAMP
  default_value: SCALAR(0x1370ef8)
  is_nullable: 0
  size: 14

=head2 extra

  data_type: TEXT
  default_value: undef
  is_nullable: 1
  size: 65535

=cut

__PACKAGE__->add_columns(
  "dist_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "package_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "ga_version",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 16,
  },
  "ga_release",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 16,
  },
  "ga_build_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "updates_version",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 16,
  },
  "updates_release",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 16,
  },
  "updates_build_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "testing_version",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 16,
  },
  "testing_release",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 16,
  },
  "testing_build_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "candidates_version",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 16,
  },
  "candidates_release",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 16,
  },
  "candidates_build_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "stamp",
  {
    data_type => "TIMESTAMP",
    default_value => \"CURRENT_TIMESTAMP",
    is_nullable => 0,
    size => 14,
  },
  "extra",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => 65535,
  },
);
__PACKAGE__->set_primary_key("dist_id", "package_id");


# Created by DBIx::Class::Schema::Loader v0.05002 @ 2010-03-04 23:10:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ADMmRybMQDW+xZ9ESOCGtg

__PACKAGE__->belongs_to(
  'dist',
  'Dist',
  { 'foreign.id' => 'self.dist_id' },
);

__PACKAGE__->belongs_to(
  'package',
  'Packages',
  { 'foreign.id' => 'self.package_id' },
);

# find the latest version generally installable version
sub current {
    my $self = shift @_;

    my $update_ver = $self->updates_version;
    my $ga_ver     = $self->ga_version;

    return $update_ver ? $update_ver : $ga_ver;
}

# determine what the td class should be for this package/version
sub update_class {
    my $self = shift @_;

    #my $current     = $self->current;
    #my $upstream_ga = $self->package->upstream_ga;
    #return 'attn' if $self->current lt $self->package->upstream_ga;
    #return 'check'

    return 'ss_sprite ss_cross' if not defined $self->current;
    return 'ss_sprite ss_accept' if not defined $self->package->upstream_ga;
    return $self->current lt $self->package->upstream_ga
         ? 'ss_sprite ss_error'
         : 'ss_sprite ss_accept'
         ;
}

1;
