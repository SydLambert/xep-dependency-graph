#!/usr/bin/env perl
use strict;
use warnings;

BEGIN {
    use File::Basename qw(dirname);
    use File::Spec;
    my $d = dirname(File::Spec->rel2abs($0));
    require "$d/setenv.pl";
}

use XML::LibXML;
use Getopt::Long;


sub find_xep_filenames {
    my $repo_dir = shift;

    opendir(FH, $repo_dir) or die "Cannot opendir $repo_dir: $!";
    my @xep_filenames = grep /^xep-\d+\.xml$/, readdir(FH);
    closedir FH;

    s/^/$repo_dir\//g for @xep_filenames;
    return @xep_filenames;
}

sub load_dom_from_filename {
    my $filename = shift;
    return XML::LibXML->load_xml(
        location => $filename,
        load_ext_dtd => 1,
    );
}

sub extract_xep_from_dom {
    my $dom = shift;

    return {
        name => "XEP-".$dom->findvalue("/xep/header/number"),
        status => $dom->findvalue("/xep/header/status"),
        type => $dom->findvalue("/xep/header/type"),
        dependencies => [
            $dom->findnodes("/xep/header/dependencies/spec")->to_literal_list()
        ],
    };
}

sub enquote {
    return shift =~ s/"//gr =~ s/^|$/"/gr;
}

sub dependency_to_color {
    $_ = shift;
    return "black" if /^XEP-\d+/i;
    return "red" if /^RFC.\d+/i;
    return "grey";
}

my $usage = <<"USAGE";
Usage: $0 <repo_path>

Example:
    $0 ./xeps/ > graph.dot
USAGE

my $repo_path = $ARGV[0] or die($usage);

my @xep_filenames = find_xep_filenames($repo_path);
my @defined_nodes;

print <<"GRAPH_PRELUDE" =~ s/ {4}/\t/gmr;
digraph {
    graph [
        overlap=false,
        pad="0.5",
        nodesep="1",
        ranksep="2"
    ];
GRAPH_PRELUDE

foreach my $filename (@xep_filenames) {
    my $dom = load_dom_from_filename($filename);
    my $xep = extract_xep_from_dom($dom);

    # TODO make options for these
    # next unless $xep->{type} =~ /Standards Track|Historical/i;
    # next unless $xep->{status} =~ /Active|Final|(Stable|Draft)/i;

    my $quoted_name = enquote($xep->{name});

    my $xep_color = dependency_to_color($xep->{name});
    print "\t$quoted_name [color=$xep_color];\n";
    push @defined_nodes, $xep->{name};

    foreach my $dep ($xep->{dependencies}->@*) {
        next if $dep =~ /^(XMPP Core|RFC 3920)$/i; # Busy enough without Core
        next if $dep =~ /^(XEP-0001|Etc.)$|OPTIONAL/i;

        $dep =~ s/^XEP.+?(\d+.*)/XEP-$1/g; # Make formatting consistent
        $dep =~ s/^((XEP|RFC)-\d+).*/$1/g; # Remove qualifier suffixes
        my $quoted_dep = enquote($dep);

        # Color non-XEP dependencies
        if ($dep !~ /^XEP/ && not grep /^$dep$/, @defined_nodes) {
            my $dep_color = dependency_to_color($dep);
            print "\t$quoted_dep [color=$dep_color];\n";
            push @defined_nodes, $dep;
        }

        print "\t$quoted_name -> $quoted_dep;\n";
    }
}

print "}\n";
