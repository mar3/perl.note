#!/usr/bin/env perl
# coding: utf-8


use strict;
use utf8;
use File::Spec::Functions;
use File::Compare;
use Getopt::Long;





sub _println {

	print(@_, "\n");
}

sub _confirm {

	print(@_, "\n(y/N)>");
	my $answer = <STDIN>;
	chomp($answer);
	if(uc($answer) eq 'Y') {
		return 1;
	}
	if(uc($answer) eq 'YES') {
		return 1;
	}
	return 0;
}

sub _install {

	my ($left, $right, $verbose) = @_;
	if(-d $left) {
		# _println('[info] copy ... [', $left, ']');
		my $handle;
		if(!opendir($handle, $left)) {
			die();
		}
		while(my $name = readdir($handle)) {
			if($name eq '.') { next }
			if($name eq '..') { next }
			my $left_pathname = File::Spec::Functions::catfile($left, $name);
			my $right_pathname = File::Spec::Functions::catfile($right, $name);
			_install($left_pathname, $right_pathname, $verbose);
		}
		closedir($handle);
	}
	elsif(-f $left) {
		if(-f $right) {
			if(File::Compare::compare($left, $right) == 0) {
				if($verbose) {
					_println('[info] nothing to do for [', $right, '].');
				}
				return;
			}
			if(!_confirm('このファイルを置き換えますか？ [', $right, ']')) {
				_println('canceled.');
				return;
			}
			system("/bin/cp", $left, $right);
		}
		else {
			if(!_confirm('この新しいファイルを作成しますか？ [', $right, ']')) {
				_println('canceled.');
				return;
			}
			system("/bin/cp", $left, $right);
		}
	}
}

sub _usage {

	_println('usage:');
	_println('  --help: show this message.');
	_println('  --source: 新しいファイルまたはディレクトリへのパス');
	_println('  --destination: 配置先');
	_println();
}

sub _main {

	binmode(STDIN, ':utf8');
	binmode(STDOUT, ':utf8');
	binmode(STDERR, ':utf8');
	my $options = {};
	my $status = Getopt::Long::GetOptions($options,
		'help!', 'source=s', 'destination=s', 'verbose!');
	if(!$status) {
		_usage();
		return;
	}
	my $source = $options->{source};
	my $destination = $options->{destination};
	my $verbose = $options->{verbose};
	if(! -e $source) {
		_usage();
		return;
	}
	if(! -e $destination) {
		if(_confirm('この新しいディレクトリを作成しますか？ [', $destination, ']')) {
			mkdir($destination);
		}
	}
	if(! -e $destination) {
		_usage();
		return;
	}
	_install($source, $destination, $verbose);
}

_main(@ARGV);

