#!perl -Tw

use strict;
use warnings;
use Test::Most tests => 49;
use Test::NoWarnings;

BEGIN {
	use_ok('HTML::SocialMedia');
}

STRING: {
	my $sm = new_ok('HTML::SocialMedia');
	ok(!defined($sm->as_string()));

	$sm = new_ok('HTML::SocialMedia' => [ twitter => 'example' ]);
	ok(!defined($sm->as_string()));
	ok(defined($sm->as_string(twitter_follow_button => 1)));
	ok($sm->as_string(twitter_tweet_button => 1) !~ /data-related/);
	ok($sm->as_string(twitter_follow_button => 1) !~ /data-lang="/);

	$ENV{'REQUEST_METHOD'} = 'GET';
	$ENV{'HTTP_ACCEPT_LANGUAGE'} = 'fr-FR';
	$ENV{'HTTP_USER_AGENT'} = 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; fr-FR; rv:1.9.2.19) Gecko/20110707 Firefox/3.6.19';
	$sm = new_ok('HTML::SocialMedia' => []);
	ok(defined($sm->as_string(facebook_like_button => 1)));
	ok($sm->as_string(facebook_like_button => 1) =~ /fr_FR/);
	# No twitter account given, so we can't get a tweet button
	ok(!defined($sm->as_string(twitter_tweet_button => 1)));

	# Asking for French with a US browser should display in French
	$ENV{'HTTP_USER_AGENT'} = 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.19) Gecko/20110707 Firefox/3.6.19';
	$ENV{'HTTP_ACCEPT_LANGUAGE'} = 'fr';
	$sm = new_ok('HTML::SocialMedia' => []);
	ok(defined($sm->as_string(facebook_like_button => 1)));
	# Handle when there is no fr_US locale for Facebook, so
	# HTML::SocialMedia falls back to en_GB.
	# TODO: It should fall back to fr_FR
	my $button = $sm->as_string(facebook_like_button => 1);
	ok(($button =~ /en_GB/) || ($button =~ /fr_US/));
	ok(!defined($sm->as_string(twitter_tweet_button => 1)));

	$ENV{'HTTP_ACCEPT_LANGUAGE'} = 'fr-FR';
	$sm = new_ok('HTML::SocialMedia' => []);
	ok(defined($sm->as_string(facebook_like_button => 1)));
	ok($sm->as_string(facebook_like_button => 1) =~ /fr_FR/);
	ok(!defined($sm->as_string(twitter_tweet_button => 1)));

	$sm = new_ok('HTML::SocialMedia' => [ twitter => 'example', twitter_related => ['example1', 'description of example1'] ]);
	ok(defined($sm->as_string(twitter_tweet_button => 1)));
	ok($sm->as_string(twitter_follow_button => 1) =~ /data-lang="fr"/);

	$ENV{'HTTP_USER_AGENT'} = 'Mozilla/5.0 (X11; Linux x86_64; rv:6.0.2) Gecko/20100101 Firefox/6.0.2 Iceweasel/6.0.2';
	$ENV{'HTTP_ACCEPT_LANGUAGE'} = 'en-gb,en;q=0.5';
	$sm = new_ok('HTML::SocialMedia' => []);
	ok(defined($sm->as_string(facebook_like_button => 1)));
	ok($sm->as_string(facebook_like_button => 1) =~ /en_GB/);
	ok(!defined($sm->as_string(twitter_tweet_button => 1)));

	$sm = new_ok('HTML::SocialMedia' => [ twitter => 'example', twitter_related => ['example1', 'description of example1'] ]);
	ok(defined($sm->as_string(facebook_like_button => 1)));
	ok($sm->as_string(facebook_like_button => 1, twitter_follow_button => 1, twitter_tweet_button => 1, google_plusone => 1) =~ /en_GB/);
	ok($sm->as_string(twitter_follow_button => 1) !~ /data-lang="/);

	$sm = new_ok('HTML::SocialMedia' => [ twitter => 'example', twitter_related => ['example1', 'description of example1'] ]);
	ok(defined($sm->as_string(twitter_tweet_button => 1)));
	ok($sm->as_string(twitter_tweet_button => 1) =~ /data-related/);
	ok($sm->as_string(twitter_tweet_button => 1) =~ /example1:description of example1/);
	ok($sm->as_string(twitter_follow_button => 1) !~ /data-lang="/);
	ok($sm->as_string(linkedin_share_button => 1) =~ /linkedin/);
	ok($sm->as_string(twitter_tweet_button => 1) !~ /linkedin/);
	ok($sm->as_string(twitter_follow_button => 1) eq $sm->render(twitter_follow_button => 1));

	$sm = new_ok('HTML::SocialMedia' => []);
	ok(defined($sm->as_string(facebook_like_button => 1)));
	ok($sm->as_string(google_plusone => 1) =~ /en-GB/);

	$ENV{'HTTP_ACCEPT_LANGUAGE'} = 'fr-FR';
	$ENV{'HTTP_USER_AGENT'} = 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; fr-FR; rv:1.9.2.19) Gecko/20110707 Firefox/3.6.19';
	$sm = new_ok('HTML::SocialMedia' => []);
	ok($sm->as_string(google_plusone => 1) =~ /fr-FR/);

	$sm = $sm->new();
	isa_ok($sm, 'HTML::SocialMedia');
	ok(defined($sm->as_string(reddit_button => 1)));
	ok($sm->as_string(reddit_button => 1) =~ /reddit\.com/);
	ok($sm->as_string(reddit_button => 1) !~ /linkedin/);
}
