# -*- perl -*-

use strict;
use Test::More tests => 7;
use lib 't/lib';
use DBSchema;
use YAML::Syck qw( Load );
use Data::Dumper;
use DvdForm;
use UserForm2;

use Rose::HTMLx::Form::DBIC qw( options_from_resultset init_with_dbic dbic_from_form );

my $schema = DBSchema::get_test_schema();
my $dvd_rs = $schema->resultset( 'Dvd' );

my $form = DvdForm->new;
options_from_resultset($form, $dvd_rs );
my @values = $form->field( 'tags' )->options;
is ( scalar @values, 3, 'Tags loaded' );

my $dvd = $schema->resultset( 'Dvd' )->find( 1 );
init_with_dbic($form, $dvd);
$form->validate;

my $value = $form->field( 'name' )->output_value;
is ( $value, 'Picnick under the Hanging Rock', 'Dvd name set' );
is_deeply ( [ $form->field( 'tags' )->internal_value ], [ '2', '3' ], 'Tags set' );
#$value = $form->field( 'creation_date' )->output_value;
#is( "$value", '2003-01-16T23:12:01', 'Date set');

my $user_form = $form->form( 'current_borrower' );
$value = $user_form->field( 'name' )->output_value;
is ( $value, 'Zbyszek Lukasiak', 'Current borrower name set' );

$form = UserForm2->new;
my $user_rs = $schema->resultset( 'User' );
options_from_resultset($form, $user_rs);
my $user = $schema->resultset( 'User' )->find( 1 );
init_with_dbic($form, $user);
my @dvd_forms = $form->form('owned_dvds')->forms();
ok( scalar @dvd_forms == 2, 'Dvd forms created' );
ok( $dvd_forms[0]->field('id')->output_value eq '1', 'Id loaded' );
#ok( $dvd_forms[0]->field('creation_date')->output_value->strftime("%Y-%m-%d %H:%M:%S") eq '2003-01-16 23:12:01', 'creation_date loaded' );
ok( $dvd_forms[1]->field('id')->output_value eq '2', 'Second row id loaded' );


