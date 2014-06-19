
use strict;
use warnings;

use Test::More;

use CPAN::Meta::Prereqs::Diff;

subtest "Addition" => sub {
  my $diff = CPAN::Meta::Prereqs::Diff->new(
    new_prereqs => { runtime => { requires => { "Some::Dependency" => "1.0" } } },
    old_prereqs => { runtime => { requires => {} } },
  );
  my @diffs = $diff->diff;
  is( scalar @diffs, 1, "1 Diff" );
  ok( $diffs[0]->is_addition, "Is addition" );
  ok( !$diffs[0]->is_removal, "Not removal" );
  ok( !$diffs[0]->is_change,  "Not change" );
  note $diffs[0]->describe;
};
subtest "Removal" => sub {
  my $diff = CPAN::Meta::Prereqs::Diff->new(
    old_prereqs => { runtime => { requires => { "Some::Dependency" => "1.0" } } },
    new_prereqs => { runtime => { requires => {} } },
  );
  my @diffs = $diff->diff;
  is( scalar @diffs, 1, "1 Diff" );
  ok( !$diffs[0]->is_addition, "Not addition" );
  ok( $diffs[0]->is_removal,   "Is removal" );
  ok( !$diffs[0]->is_change,   "Not change" );
  note $diffs[0]->describe;

};
subtest "No Change" => sub {
  my $diff = CPAN::Meta::Prereqs::Diff->new(
    old_prereqs => { runtime => { requires => { "Some::Dependency" => "1.0" } } },
    new_prereqs => { runtime => { requires => { "Some::Dependency" => "1.0" } } },
  );
  my @diffs = $diff->diff;
  is( scalar @diffs, 0, "0 Diffs" );

};
subtest "Change upgrade Change" => sub {
  my $diff = CPAN::Meta::Prereqs::Diff->new(
    old_prereqs => { runtime => { requires => { "Some::Dependency" => "0.9" } } },
    new_prereqs => { runtime => { requires => { "Some::Dependency" => "1.0" } } },
  );
  my @diffs = $diff->diff;
  is( scalar @diffs, 1, "1 Diffs" );
  ok( !$diffs[0]->is_addition, "Not addition" );
  ok( !$diffs[0]->is_removal,  "Not removal" );
  return unless ok( $diffs[0]->is_change, "Is change" );
  ok( $diffs[0]->is_upgrade,    "Is Upgrade" );
  ok( !$diffs[0]->is_downgrade, "Not Downgrade" );
  note $diffs[0]->describe;

};
subtest "Change downgrade Change" => sub {
  my $diff = CPAN::Meta::Prereqs::Diff->new(
    old_prereqs => { runtime => { requires => { "Some::Dependency" => "1.0" } } },
    new_prereqs => { runtime => { requires => { "Some::Dependency" => "0.9" } } },
  );
  my @diffs = $diff->diff;
  is( scalar @diffs, 1, "1 Diffs" );
  ok( !$diffs[0]->is_addition, "Not addition" );
  ok( !$diffs[0]->is_removal,  "Not removal" );
  return unless ok( $diffs[0]->is_change, "Is change" );
  ok( !$diffs[0]->is_upgrade,  "Not Upgrade" );
  ok( $diffs[0]->is_downgrade, "Is Downgrade" );
  note $diffs[0]->describe;

};

subtest "Change mixed Change" => sub {
  my $diff = CPAN::Meta::Prereqs::Diff->new(
    old_prereqs => { runtime => { requires => { "Some::Dependency" => "<1.0" } } },
    new_prereqs => { runtime => { requires => { "Some::Dependency" => ">0.9" } } },
  );
  my @diffs = $diff->diff;
  is( scalar @diffs, 1, "1 Diffs" );
  ok( !$diffs[0]->is_addition, "Not addition" );
  ok( !$diffs[0]->is_removal,  "Not removal" );
  return unless ok( $diffs[0]->is_change, "Is change" );
  ok( !$diffs[0]->is_upgrade,   "Not Upgrade" );
  ok( !$diffs[0]->is_downgrade, "Not Downgrade" );
  note $diffs[0]->describe;

};

done_testing;

