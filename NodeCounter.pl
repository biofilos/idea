#! /usr/bin/perl -w

##-------------------------------------------------------
#	NodeCounter.pl		Author: Russell Hermansen
#
#	Counts the number of nodes within a tree
#	Gives the total number of nodes, the number of leaf
#	nodes, and the number of internal nodes.
#
#	USAGE: perl NodeCounter.pl <Input.newick>
#
#	NOTE: Bio::Perl must be install in order to run
##--------------------------------------------------------

use strict;
use Bio::TreeIO;

my $treeIO = Bio::TreeIO->new(-file => "$ARGV[0]", -format => 'newick');
my $tree = $treeIO->next_tree();

#my @nodes = $tree->nodes;
my $root = $tree->get_root_node();
my @nodes = $root->get_all_Descendents;

my $size = @nodes + 1;

print "Node count total: $size\n";
my @leafNodes = $tree->get_leaf_nodes;
$size = @leafNodes;
print "Leaf Nodes: $size\n";

my @internalNodes = ();
foreach my $node (@nodes){
	my $flag = 0;
	foreach my $leaf (@leafNodes){
		if ($node eq $leaf){
			$flag = 1;
			last;
		}
	}
	if ($flag == 0){
		push (@internalNodes, $node);
	}
}
my $total_length = $tree->total_branch_length;
print "treelength: $total_length\n";
$size = @internalNodes + 1;
print "Internal Nodes: $size\n";
