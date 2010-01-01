package Fedora::App::Updates::Schema::Result::YumReposLog;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("yum_repos_log");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "repo_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "stamp",
  {
    data_type => "TIMESTAMP",
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 0,
    size => 14,
  },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-12-28 15:58:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9WN9+uPJF6pTYVC1qodp7Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;