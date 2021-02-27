#!/usr/bin/perl

use warnings;
use strict;
use JSON;
use JSON::Create 'write_json';
# use JSON::Create 'create_json';
use File::Slurp;
use Data::Dumper qw(Dumper);


my $path = "/home/shreyam/.config/watson/";
my $state_path = make_path("state");
my $state_bak_path = make_path("state.bak");
sub parse_args{
    my $len = $#ARGV;
    #print "$len";
    if($ARGV[0] eq "start"){
        start(time());
    }
    else {
        my $arg_str;
        foreach my $arg(@ARGV){
            $arg_str .=  " " . $arg; 
        }
        system("watson $arg_str");
    }
    # elsif($ARGV[0] eq "stop"){
    #     stop(time());
    # }
}

sub get_project_and_tags_from_args{

    my $arg_str = "";
    # print("running...\n");
    
    my $project_name;
    my $is_tag = 0;
    my @tags;
    foreach my $test(@ARGV[1..@ARGV-1]){

        if(substr($test, 0, 1) eq "+"){
            $is_tag = 1;
            push(@tags, substr($test,1));
        }
        elsif($is_tag == 1){
            # my $tag_len = $#tags;
            $tags[@tags-1] =  $tags[@tags-1] ." ".$test;
        }
        else{
            if($project_name){
                $project_name = $project_name . " " . $test;
            }
            else{
                $project_name = $test;
            }
        }
    }
    
    return ($project_name, @tags);

}

sub error_exit{
    print $_[0];
    exit 0;
}

sub check_if_exists {
    open(my $fh, "<", $_[0]) or return 0;
    return 1;
}

sub stop {

}

sub start {
    
    # my %state = get_json_data($state_path);
    # my %state_bak = get_json_data($state_bak_path);
    my $project_name;
    my @tags;
    
    

    ($project_name, @tags) = get_project_and_tags_from_args();
    if(!$project_name){
        error_exit("Please enter valid project name");
    }
    # print("Projectname: $project_name \n");
    # print("Tags: @tags\n");

    my $state_exist = check_if_exists($state_path);
    if($state_exist) {
        my %state = get_json_data($state_path);
        if($state{project}) {
            print("ERROR:: Please close open projects before issuing a start command");
            exit 1;
        }
        else {
            system("rm $state_bak_path");
            system("cp $state_path $state_bak_path");
            system("rm $state_path");
            my %state;
            $state{"start"} = $_[0];
            $state{"project"} = $project_name;
            $state{"tags"} = [@tags]; 
            write_json($state_path, \%state);
        }
    } else {
        my %state;
        $state{"start"} = $_[0];
        $state{"project"} = $project_name;
        $state{"tags"} = [@tags]; 
        write_json($state_path, \%state);
    }

    
    
}

sub make_path{
    my $path_formed = $path . $_[0];
    return $path_formed;
}

sub get_json_data{
    # print "HI!";
    # my %empty_hash;
    # open(my $fh, "<", $_[0]) or return %empty_hash;
    # my $test = <$fh>;

    # while (my $row = <$fh>) {
    # chomp $row;
    # print "$row\n";
    # }


    my $test = read_file($_[0]);
    
    # print $test;
    my %testdata = %{decode_json($test)};
    # my $len = keys %testdata;

    return %testdata;
    
}

parse_args();
# get_project_and_tags_from_args;
# start();

# my $var="state";
# get_json_data($var);
# # print make_path("state")
