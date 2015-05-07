use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Blog';
use Blog::Controller::Root;

ok( request('/root')->is_success, 'Request should succeed' );
done_testing();
