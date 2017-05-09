#!/usr/bin/perl
########################################################################
#
# max_index.pl		V2	Works with Tkx instead of Tk
#				Works with Olympus files
#                       Runs various Perl commands to find hi water mark for image files
#
########################################################################



#-----------------------------------------------------------------------
#
#  Overall Control
#
#-----------------------------------------------------------------------
#use strict 'vars';
use warnings;
use English;
use Tkx;
use File::Basename;

$SIG{INT} = 'IGNORE';


#-----------------------------------------------------------------------
#
#  Platform-Independent Environmental Variables
#
#-----------------------------------------------------------------------

#  Constants


#  Flow Control


#  Variables


$denyce_max_count = 0;
$denyce_max_dir = "";

$black_max_count = 0;
$black_max_dir = "";

$silver_max_count = 0;
$silver_max_dir = "";

$droid_max_count = 0;
$droid_max_dir = "";

$stylus_max_count = 0;
$stylus_max_dir = "";



$pointer = "";


#  Files and Directories

$image_dir    = "Digitial Sequences";
$image_dir    = "DIGITA~1";

$black_sema_file = "black.txt";
$silver_sema_file = "silver.txt";
$denyce_sema_file = "Denyce.txt";
$droid_sema_file = "DROID.txt";


#  Messages



#-----------------------------------------------------------------------
#
#  Main Routine
#
#-----------------------------------------------------------------------

opendir(PARENT, $image_dir) or die "Cannot open directory $image_dir: $!";
@dir_list = readdir(PARENT);
closedir(PARENT);
@dir_names = f_dir_list(@dir_list);

foreach $parent_name (@dir_names) {
    $parent_dir = "$image_dir/$parent_name";

    opendir(CHILD, $parent_dir) or die "Cannot open directory $parent_dir: $!";
    while (defined($file_name = readdir(CHILD))) {
        next if $file_name =~ /^\.\.?$/;			# skip . and ..
        ($base, $dir, $ext) = fileparse($file_name, '\..*');

        $CAP_ext = $ext;
        $CAP_ext =~ tr/a-z/A-Z/;			#Convert extension to upper case

#        next if ($CAP_ext ne ".JPG"); 			#Skip non-JPEG files
        next if ( ($CAP_ext ne ".JPG") && ($CAP_ext ne ".CR2") && ($CAP_ext ne ".ORF") && ($CAP_ext ne ".AVI") && ($CAP_ext ne ".MOV") ); 			#Skip non-relevant files

        next unless ( $base =~ /\d{5}$/ );		#Skip files not ending in 5 digits

        $offset = (length($base) - 5);			#Extract last 5 digits as numerical index
        $extract = substr($base, $offset);
        $index = abs($extract); 


        if ( $base =~ /S3IS/ ) {

            if ( $index > $black_max_count ) {
                $black_max_count = $index;
                $black_max_dir = $parent_name;
            }
        }
        elsif ( $base =~ /S45/ ) {

            if ( $index > $silver_max_count ) {
                $silver_max_count = $index;
                $silver_max_dir = $parent_name;
            }     
        }
        elsif ( $base =~ /40D/ ) {

            if ( $index > $denyce_max_count ) {
                $denyce_max_count = $index;
                $denyce_max_dir = $parent_name;
            }     
        }
        elsif ( $base =~ /Stylus1S/ ) {

            if ( $index > $stylus_max_count ) {
                $stylus_max_count = $index;
                $stylus_max_dir = $parent_name;
            }     
        }
        elsif ( $base =~ /DROID/ ) {

            if ( $index > $droid_max_count ) {
                $droid_max_count = $index;
                $droid_max_dir = $parent_name;
            }     
        }

    }
    
    closedir(CHILD);
}

if ( -f $black_sema_file  ) {
    $pointer = "Black Beauty";
}
elsif (  -f $silver_sema_file ) {
    $pointer = "Silver Lass";
}
elsif (  -f $denyce_sema_file ) {
    $pointer = "Denyce";
}
elsif (  -f $droid_sema_file ) {
    $pointer = "DROID";
}

else {
    $pointer = "Unspecified";
}




my $mw = Tkx::widget->new(".");
$mw->g_wm_title("Max Index Locator");
$mw->g_wm_minsize(300, 200);

my $label_one = $mw->new_label (-text => "Denyce (40D):  $denyce_max_dir  : $denyce_max_count ", -font=> "Courier 12 bold" );
$label_one->g_pack ( -padx => 10, -pady => 5);

my $label_two = $mw->new_label (-text => "Black Beauty  (S3IS):  $black_max_dir :  $black_max_count ", -font=> "Courier 12 bold" );
$label_two->g_pack ( -padx => 10, -pady => 5);

my $label_three = $mw->new_label (-text => "Silver Lass  (S45):    $silver_max_dir :  $silver_max_count", -font=> "Courier 12 bold" );
$label_three->g_pack ( -padx => 10, -pady => 5);

my $label_four = $mw->new_label (-text => "Olympus Stylus:     $stylus_max_dir :  $stylus_max_count ", -font=> "Courier 12 bold" );
$label_four->g_pack ( -padx => 10, -pady => 5);

my $label_five = $mw->new_label (-text => "Motorola DROID:     $droid_max_dir :  $droid_max_count ", -font=> "Courier 12 bold" );
$label_five->g_pack ( -padx => 10, -pady => 5);

my $button_one;
$button_one = $mw->new_button(
	-text => "Exit",
	-font => "Courier 12 bold",
	-command => sub { $mw->g_destroy; }
);
$button_one->g_pack;

Tkx::MainLoop();

exit 0;

#-----------------------------------------------------------------------
#
#  Functions
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
#
#  Function:  f_dir_list
#  Purpose:   Removes dots from contents of directory list
#
#
#       Tangible Action:           None
#       Internal Action:           None
#       User Interaction:          None
#       Passed parameters          List to reduce
#       New Global Variables:      None
#
#       Global Variables Changed:  None
#       Global Variables Used:     None
#       Returns:                   Reduced list
#
#-----------------------------------------------------------------------

sub f_dir_list {

    my %seen = ();
    my @uniq = ();
    my $item;
    foreach $item (@_) {
        if ($item eq ".") {
        } elsif ($item eq "..") {
        } else {
        push( @uniq, $item );
        }

    }
    return @uniq;
}

