#!/usr/bin/perl

# Copyright (c) 2016 Wind River Systems, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# applyPatch.pl - Apply a patch to a git repo

# modification history
# --------------------
# 16feb16,jdw  Created 
#
# DESCRIPTION 
#
# This script applies patch data to a git repo based on a config.json file.
#
# Arguments: 
#  <patch name> <patch data dir> <target dir>

use strict;
use File::Path qw( make_path );
use File::Copy;
use File::Basename;
use File::Spec::Functions;
use Cwd qw( abs_path getcwd cwd );

use JSON::Tiny qw(decode_json);

my $patchName = shift;
my $patchesDir = shift;
my $tgtDir = shift;

die "ERROR: Invalid arguments!\n" 
    unless ( defined $patchName && 
	     ( -d $patchesDir ) &&
	     ( -d $tgtDir ) );

# External git utility
my $git = "git";

my $user=`whoami`;
chomp $user;

# Routine to get the config data from a file
sub getCfgDataFromFile
{
    my $cfgFile = shift;
    my $f;

    open( $f, "<", $cfgFile ) or
	logMsg( "Error: Can't open $cfgFile", { fatal => 1 } );

    my $data = join( "", <$f> );

    close( $f );

    return $data;    
}

# Routine to get the JSON config into a structure we can work with
sub parseCfgData
{
    my $jsonData = shift;

    my $cfgHash = decode_json $jsonData;

    return $cfgHash;
}

my $cfgFile = catfile( $patchesDir, "config.json" );

my $cfgData = getCfgDataFromFile( $cfgFile );

my $cfgRef = parseCfgData( $cfgData );

my %cfg = %{ $cfgRef };
 
die "ERROR: Can't find specified patch [ $patchName ] in config file [ $cfgFile ]!\n"
    unless ( $cfg{ project_data }{ patches }{ $patchName } );

# Get the info we need to patch from the config file
my $patchFile = $cfg{ project_data }{ patches }{ $patchName }{ file };
my $repoSha = $cfg{ project_data }{ patches }{ $patchName }{ target_sha };
my $repoBranch = $cfg{ project_data }{ patches }{ $patchName }{ target_branch };

my $patch = abs_path( catfile( $patchesDir, $patchFile ) );

die "Error: Can't find patch file [ $patch] to apply!!\n" 
    unless ( -r "$patch" );

my $dir = cwd();

die "ERROR: can't change to patch target directory!\n"
    unless ( chdir( $tgtDir ) );

my $cmd;
my $rslt;

if ( defined $repoSha )
{
    # Check out the specified SHA before proceeding
    $cmd = "git checkout $repoSha 2>&1";
    $rslt = `$cmd`;
    
    die "ERROR: Can't checkout at SHA[ $repoSha ]!\n"
	unless ( 0 == $? );
}
else
{
    # Check out the specified branch before proceeding
    $cmd = "git checkout $repoBranch 2>&1";
    $rslt = `$cmd`;
    
    die "ERROR: Can't checkout branch[ $repoBranch ]!\n"
	unless ( 0 == $? );
}

# Create a branch to apply the patch changes
$cmd = "git checkout -b $user"."_"."$patchName 2>&1";
$rslt = `$cmd`;

die "ERROR: Can't checkout branch [ $user"."_"."$patchName ] for patch!\n"
    unless ( 0 == $? );

# If the patch is compressed with .zip
if ( $patch =~ m|\.zip\s*$| )
{
    $cmd = "unzip -p $patch | git am -q --ignore-whitespace 2>&1";
}
else
{
    # Assume the patch isn't compressed
    $cmd = "git am -q --ignore-whitespace < $patch 2>&1";
}

$rslt = `$cmd`;

die "ERROR: Patching operation failed!\n"
    unless ( 0 == $? );

exit 0;
