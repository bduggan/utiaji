use lib 'lib';
use Test;
use Hamna::App::Templater;
use Hamna::Test;

my $app = Hamna::App::Templater.new;

my $t = Hamna::Test.new.start($app);

$t.get-ok('/hello').status-is(200).content-is("<html>\n<b>Hello</b> world.\n</html>\n\n");

$t.get-ok('/hello/there').status-is(200).content-is("<html>\nHello <b>there</b>.\n</html>\n\n");

$t.get-ok('/headfoot').status-is(200).content-is(q:to/DONE/);
This is a header.

body
This is a footer.

DONE

$t.stop;

done-testing;

