#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 42;
use Test::Exception;

BEGIN {
	use_ok('Tree::Simple::Manager');
    use_ok('Tree::Simple');
}

can_ok('Tree::Simple::Manager', 'new');

{

    my $tree_manager = Tree::Simple::Manager->new(
        'Test Tree' => {
            tree_root      => Tree::Simple->new(Tree::Simple->ROOT),
            tree_file_path => "t/test.tree"
            }
        );
    isa_ok($tree_manager, 'Tree::Simple::Manager');
    
    can_ok($tree_manager, 'getTreeList');
    can_ok($tree_manager, 'getRootTree');
    can_ok($tree_manager, 'getTreeIndex');
    can_ok($tree_manager, 'getTreeByID');    
    can_ok($tree_manager, 'getTreeViewClass');
    can_ok($tree_manager, 'getNewTreeView');    
    
    is_deeply(
        [ $tree_manager->getTreeList() ],
        [ 'Test Tree' ],
        '... got the right list');
    
    is_deeply(
        scalar $tree_manager->getTreeList(),
        [ 'Test Tree' ],
        '... got the right list');
    
    my $tree;
    lives_ok {
        $tree = $tree_manager->getRootTree("Test Tree");
    } '... got the root tree ok';
    ok(defined($tree), '... got a tree back');
    isa_ok($tree, 'Tree::Simple');
    
    my $II_I_I;
    lives_ok {
        $II_I_I = $tree_manager->getTreeByID('Test Tree' => 8);
    } '... got the tree ok';
    isa_ok($II_I_I, 'Tree::Simple');
    is($II_I_I->getNodeValue(), 'II.I.I', '... got the right node');
    
    my $tree_index;
    lives_ok {
        $tree_index = $tree_manager->getTreeIndex("Test Tree");
    } '... got the tree index back ok';
    isa_ok($tree_index, 'Tree::Simple::Manager::Index');
    is($tree_index->getRootTree(), $tree, '... and it is the same as we expected');
    
    my $tree_view_class;
    lives_ok {
        $tree_view_class = $tree_manager->getTreeViewClass("Test Tree");
    } '... got the tree view class okay';
    is($tree_view_class, 'Tree::Simple::View::DHTML', '... got the right view class');

    my $tree_view;
    lives_ok {
        $tree_view = $tree_manager->getNewTreeView("Test Tree");
    } '... got the tree view class okay';
    isa_ok($tree_view, 'Tree::Simple::View::DHTML');
    
}

{

    {
        package My::TreeView;
        
        package My::TreeIndex;
        sub new { bless {} } 
    }

    my $tree_manager = Tree::Simple::Manager->new(
        "Test Tree" => {
            tree_root      => Tree::Simple->new(Tree::Simple->ROOT),
            tree_file_path => "t/test.tree",
            tree_index     => 'My::TreeIndex',
            tree_view      => 'My::TreeView',
            }
        );
    isa_ok($tree_manager, 'Tree::Simple::Manager');
    
    my $tree_index = $tree_manager->getTreeIndex("Test Tree");
    isa_ok($tree_index, 'My::TreeIndex');
    
    my $tree_view = $tree_manager->getTreeViewClass("Test Tree");
    is($tree_view, 'My::TreeView', '... got the right view class');
    
}

# check errors

{
    
    throws_ok {
        Tree::Simple::Manager->new();
    } "Tree::Simple::Manager::InsufficientArguments", '... this should die';
    
    throws_ok {
        Tree::Simple::Manager->new('Fail' => {});
    } "Tree::Simple::Manager::InsufficientArguments", '... this should die';    

    throws_ok {
        Tree::Simple::Manager->new('Fail' => { tree_root => 1 });
    } "Tree::Simple::Manager::InsufficientArguments", '... this should die';    
    
    throws_ok {
        Tree::Simple::Manager->new('Fail' => { tree_file_path => 1 });
    } "Tree::Simple::Manager::InsufficientArguments", '... this should die';     
    
    throws_ok {
        Tree::Simple::Manager->new(
            'Fail' => { tree_root => Tree::Simple->new(), tree_file_path => "t/test.tree" },
            'Fail' => { tree_root => Tree::Simple->new(), tree_file_path => "t/test.tree" }
            );
    } "Tree::Simple::Manager::DuplicateName", '... this should die';       
    

    throws_ok {
        Tree::Simple::Manager->new(
            'Fail' => { tree_root => bless({}, 'Fail'), tree_file_path => "t/test.tree" },
            );
    } "Tree::Simple::Manager::IncorrectObjectType", '... this should die'; 
    
    throws_ok {
        Tree::Simple::Manager->new(
            'Fail' => { tree_root => Tree::Simple->new(), tree_file_path => "t/test.tree.fail" },
            );
    } "Tree::Simple::Manager::OperationFailed", '... this should die';          

    my $tree_manager = Tree::Simple::Manager->new(
        "Test Tree" => {
            tree_root      => Tree::Simple->new(Tree::Simple->ROOT),
            tree_file_path => "t/test.tree"
            }
        );
    isa_ok($tree_manager, 'Tree::Simple::Manager');
    
    throws_ok {
        $tree_manager->getRootTree();
    } "Tree::Simple::Manager::InsufficientArguments", '... this should die';
    
    throws_ok {
        $tree_manager->getRootTree("Fail");
    } "Tree::Simple::Manager::KeyDoesNotExist", '... this should die';
    
    
    throws_ok {
        $tree_manager->getTreeIndex();
    } "Tree::Simple::Manager::InsufficientArguments", '... this should die';
    
    throws_ok {
        $tree_manager->getTreeIndex("Fail");
    } "Tree::Simple::Manager::KeyDoesNotExist", '... this should die';
    
    
    throws_ok {
        $tree_manager->getTreeViewClass();
    } "Tree::Simple::Manager::InsufficientArguments", '... this should die';
    
    throws_ok {
        $tree_manager->getTreeViewClass("Fail");
    } "Tree::Simple::Manager::KeyDoesNotExist", '... this should die';
    
}
