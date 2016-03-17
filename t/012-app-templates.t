use lib 'lib';
use Test;
use Utiaji::App::Templater;
use Utiaji::Test;

my $app = Utiaji::App::Templater.new;

my $t = Utiaji::Test.new.start($app);

$t.get-ok('/hello').status-is(200).content-is("<html>\n<b>Hello</b> world.\n</html>\n\n");

done-testing;

