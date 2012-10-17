use Test;

use OpenSubtitles;
use File::Spec;

plan tests => 1;

########################################################
# Setup - Load mock data
########################################################

#my $can = File::Spec->catfile("t", "canned", "queue_list.xml");
#open FILE, "<$can" or die "Cannot open $can";
#my $data = join '', <FILE>;
#close FILE;
#$Boxee::Queue::CANNED_RESPONSE = $data;

my $os_api = OpenSubtitles->new();

########################################################
# Test 'search'
########################################################

my @q = $os_api->search('test.mkv');

ok($#q, 0);