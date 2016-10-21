requires 'DBIx::Class' => 0;
requires 'DBIx::Class::Candy' => 0;
requires 'DBIx::Class::DeploymentHandler' => 0;
requires 'OpusVL::AppKit' => 0;
requires 'OpusVL::Preferences' => 0.13;
requires 'OpusVL::AppKitX::PasswordReset' => 0;
requires 'Text::CSV' => 0;
requires 'DBIx::Class::Helper::ResultSet::SetOperations' => 0;
requires 'Code4Health::LDAP' => 0;
requires 'HTML::FormHandler::Moose' => 0;

on build => sub {
   requires 'Test::More' => 0;
   requires 'Test::Compile' => 0;
   requires 'Test::DBIx::Class' => 0;
   requires 'Test::PostgreSQL' => 0;
};
