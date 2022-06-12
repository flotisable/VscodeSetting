#!/usr/bin/perl
use strict;
use warnings;

use FindBin;
use File::Basename;
use File::Path        qw/make_path remove_tree/;
use Term::ANSIColor;
use File::Temp;
use File::Copy;
use Cwd               qw/getcwd abs_path/;
use File::Spec;

$ENV{GIT_EDITOR} = 'cat';

my %programs =  (
                  git => "git",
                );

my %paths;

( undef, $paths{rootDir} ) = fileparse( $FindBin::Bin );

$paths{testDir} = "$paths{rootDir}/Test";
@paths{qw/sourceDir targetDir logDir/} = map { "$paths{testDir}/$_" } qw/Source Target Logs/;

my $targetFile = "testTarget.txt";
my $isTestPass = 1;

exit main();

sub main
{
  my @oses =  (
                'Linux',
                'Windows',
                'Macos',
              );

  my @tests = (
                'copy',
                'uninstall',
                'install',
                'sync-main-to-local',
                'sync-main-from-local',
                'sync-to-local',
              );
  my $fh;

  remove_tree( $paths{testDir} );
  make_path( @{paths}{qw/sourceDir logDir/} );

  for my $os ( @oses )
  {
    print "OS $os can not be tested, skip\n" and next unless isOsTestable( $os );
    print "Test OS $os\n";

    osNameToOsEnv( $os );

    $paths{osTargetDir} = "$paths{targetDir}/${os}";

    make_path( $paths{osTargetDir} );
    open $fh, '>', "$paths{osTargetDir}/${targetFile}" and close $fh;

    testMakefileTarget( $_, $os ) for @tests;
  }
  remove_tree( $paths{testDir} ) if $isTestPass;

  return 0;
}

# test infrastructure
sub getOsExpectedShell
{
  my $os = shift;

  my %osMap = (
                Linux   => 'sh',
                Windows => 'powershell',
                Macos   => 'sh',
              );

  return $osMap{$os} // '';
}

sub isOsTestable
{
  my $os = shift;

  my $shell   = getOsExpectedShell( $os );
  my $devNull = File::Spec->devnull();

  return ( system "$shell -help > $devNull 2>&1" )? 0: 1;
}

sub osNameToOsEnv
{
  my $os = shift;

  my %osMap = (
                Linux   => 'Linux',
                Windows => 'Windows_NT',
                Macos   => 'Darwin',
              );

  $ENV{OS} = $osMap{$os} if exists $osMap{$os};
}

sub setPassColor
{
  print color( 'green' ) if -t;
}

sub setFailColor
{
  print color( 'red' ) if -t;
}

sub resetColor
{
  print color( 'reset' ) if -t;
}

sub testMakefileTarget
{
  my ( $target, $os ) = @_;

  my $log       = "$paths{logDir}/${target}_${os}.log";
  my $testInput = testInput( $target );

  prepareTest( $target, $log );

  print "[Test makefile target '$target']\n";
  system( "echo '$testInput' | make --no-print-directory $target > $log 2>&1" );

  if( $? >> 8 == 0 )
  {
    setPassColor();
    print "Test pass\n";
    unlink $log
  }
  else
  {
    setFailColor();
    print "Test fail\n";
    $isTestPass = 0
  }
  resetColor();

  cleanupTest( $target )
}

sub testInput
{
  my $target = shift;

  my %inputs =  (
                  'sync-main-from-local' => ':qa',
                  'sync-to-local'        => ':qa',
                );

  return $inputs{$target} // '';
}

sub prepareTest
{
  my ( $target, $log ) = @_;

  my %functions = (
                    'sync-main-to-local'    => \&prepareTestSyncRemoteToLocal,
                    'sync-main-from-local'  => \&prepareTestSyncMainFromLocal,
                    'sync-to-local'         => \&prepareTestSyncMainToLocalMachine,
                  );

  $functions{$target}->( $log ) if exists $functions{$target};
}

sub cleanupTest
{
  my $target = shift;

  chdir $paths{rootDir};
}
# end test infrastructure

# individual test settings
sub prepareTestSyncRemoteToLocal
{
  my $log = shift;

  gitClone( '.', "$paths{osTargetDir}/remote",  $log );
  gitClone( '.', "$paths{osTargetDir}/local",   $log );

  chdir "$paths{osTargetDir}/local";

  system "$programs{git} config --local commit.gpgsign             false >> $log 2>&1";
  system "$programs{git} config --local pull.rebase                false >> $log 2>&1";
  system "$programs{git} config --local branch.main.mergeOptions   '--strategy=ort --strategy-option=ours' >> $log 2>&1";
  system "$programs{git} config --local branch.local.mergeOptions  '--strategy=ort --strategy-option=ours' >> $log 2>&1";
  system "$programs{git} branch -m main >> $log 2>&1";
  system "$programs{git} branch local >> $log 2>&1";
  system "$programs{git} checkout main >> $log 2>&1";
  system "$programs{git} remote add remote ../remote >> $log 2>&1";
  system "$programs{git} fetch remote >> $log 2>&1";
  system "$programs{git} branch --set-upstream-to=remote/main >> $log 2>&1";

  replaceFileLine( 'dataFile', 'Target', 'Main', 'settings.toml' );
  system "$programs{git} commit -am 'change target file' >> $log 2>&1";

  chdir "../remote";

  system "$programs{git} branch -m main >> $log 2>&1";
  system "$programs{git} config --local commit.gpgsign false >> $log 2>&1";
  replaceFileLine( 'dataFile', 'Target', 'Remote', 'settings.toml' );
  system "$programs{git} commit -am 'change target file' >> $log 2>&1";

  chdir "../local";

  system "$programs{git} checkout local >> $log 2>&1";
  replaceFileLine( 'dataFile', 'Main', 'Local', 'settings.toml' );
  system "$programs{git} commit -am 'change target file' >> $log 2>&1";
}

sub prepareTestSyncMainFromLocal
{
  my $log = shift;

  gitClone( '.', "$paths{osTargetDir}/main", $log );

  chdir "$paths{osTargetDir}/main";

  system "$programs{git} branch -m main >> $log 2>&1";
  system "$programs{git} config --local commit.gpgsign           false >> $log 2>&1";
  system "$programs{git} config --local branch.main.mergeOptions '--strategy=ort --strategy-option=ours' >> $log 2>&1";
  replaceFileLine( 'dataFile', 'Target', 'Main', 'settings.toml' );
  system "$programs{git} commit -am 'change target file' >> $log 2>&1";
  system "$programs{git} checkout -b local >> $log 2>&1";
  replaceFileLine( 'dataFile', 'Target', 'Local', 'settings.toml' );
  system "$programs{git} commit -am 'change target file' >> $log 2>&1";
  system "$programs{git} checkout main >> $log 2>&1";
  replaceFileLine( 'dataFile', 'Main', 'Main2', 'settings.toml' );
  system "$programs{git} commit -am 'change remote branch' >> $log 2>&1";
  system "$programs{git} checkout local >> $log 2>&1";
  replaceFileLine( 'dataFile', 'Local', 'Local2', 'settings.toml' );
}

sub prepareTestSyncMainToLocalMachine
{
  my $log = shift;

  my $fh;

  gitClone( '.', "$paths{osTargetDir}/toLocalMachine", $log );

  chdir "$paths{osTargetDir}/toLocalMachine";

  system "$programs{git} branch -m main >> $log 2>&1";
  make_path( @paths{qw/sourceDir osTargetDir/} );
  open $fh, '>', "$paths{sourceDir}/testSource.txt" and close $fh;
  system "$programs{git} config --local commit.gpgsign             false >> $log 2>&1";
  system "$programs{git} config --local branch.local.mergeOptions  '--strategy=ort --strategy-option=ours' >> $log 2>&1";
  replaceFileLine( 'dataFile', 'Target', 'Main', 'settings.toml' );
  system "$programs{git} commit -am 'change target file' >> $log 2>&1";
  system "$programs{git} branch local >> $log 2>&1";
  replaceFileLine( 'dataFile', 'Target', 'Main2', 'settings.toml' );
  system "$programs{git} commit -am 'change target file' >> $log 2>&1";
  system "$programs{git} checkout local >> $log 2>&1";
  replaceFileLine( 'dataFile', 'Target', 'Local', 'settings.toml' );
  system "$programs{git} commit -am 'change target file' >> $log 2>&1";
  system "$programs{git} checkout main >> $log 2>&1";
  replaceFileLine( 'dataFile', 'Target', 'Main3', 'settings.toml' );
}
# end individual test settings

# helper functions
sub replaceFileLine
{
  my ( $linePattern, $pattern, $replace, $file ) = @_;

  local $_; # to avoid override @tests in main function, since the for loop use $_;

  my $tmpFh = File::Temp->new();

  open my $fh, '<', $file or die "Can not open file $file!";

  while( <$fh> )
  {
    if( /$linePattern/ )
    {
      print $tmpFh s/$pattern/$replace/r;
    }
    print $tmpFh $_;
  }
  close $fh;

  close $tmpFh;
  move( $tmpFh->filename, $file );
}

sub gitClone
{
  my ( $from, $to, $log ) = @_;

  my $pwd;
  my $isChdir = 0;

  system "$programs{git} clone $from $to >> $log 2>&1";

  $pwd = getcwd() and $isChdir = 1 and chdir $from unless abs_path( getcwd() ) eq abs_path( $from );

  for my $file ( qx/$programs{git} diff-index --name-only HEAD/ )
  {
    chomp $file;
    my $fromFile  = "$from/$file";
    my $toFile    = "$to/$file";

    copy( "$fromFile", "$toFile" ) or die "fail to copy $fromFile to $toFile";
  }
  chdir $pwd if $isChdir;
}
# end helper functions
