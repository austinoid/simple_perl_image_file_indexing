#!/usr/bin/perl
########################################################################
#
# Rename_with_EXIF.pl
#                       Runs various Perl commands to rename and correct sequence number on image file names
#        			using EXIF data, including JPG and AVI files.
#
#
#			Developed by and copyright by Carl Gusler.
#
########################################################################

#-----------------------------------------------------------------------
#
#  Version History
#			Version 3.5: Supports my personal Canon and Olympus (Stylus) cameras
#			Version 3.4: Special for borrowed Olympus camera
#			Version 3.3: Supports Canon and Olympus Raw
#					File pairs not necessary, but only supports specific file formats
#			Version 3.2: First support for both Canon and Olympus Raw formats
#					Lots of issues with file pairs and sequence as found by search program
#					Requires cameras set for image file pairs (RAW+JPG)
#			Version 3T:  Uses GUI based on Tkx   (Tidied)
#					Receives starting value as GUI input
#			Version 2:  Supports my Canon and Olympia 1S cameras
#
#
#-----------------------------------------------------------------------
#

####
#
#  Future Improvements Needed
#	1)  Input validation from GUI
#	2)  Fuller validation of EXIF dates

#-----------------------------------------------------------------------
#
#  Overall Control
#
#-----------------------------------------------------------------------
#use strict 'vars';
use English;
use Tkx;

#use Image::Info;
use File::Basename;
use File::Find;

$SIG{INT} = 'IGNORE';

#-----------------------------------------------------------------------
#
#  Platform-Independent Environmental Variables
#
#-----------------------------------------------------------------------

#  Constants

#  Flow Control

#  Variables

#  Files and Directories

#  Messages

#-----------------------------------------------------------------------
#
#  Main Routine
#
#-----------------------------------------------------------------------

my $label1 = "Photo Sequence Starter";
my $label2 = "    ";

my $entry_variable1 = "0";

my $mw = Tkx::widget->new(".");
$mw->g_wm_title("File Rename from EXIF");
$mw->g_wm_minsize( 300, 200 );

my $label_one =
  $mw->new_label( -textvariable => \$label1, -font => "Courier 12 bold" );
$label_one->g_pack( -padx => 10, -pady => 10 );

my $entry_line1 = $mw->new_entry( -text => \$entry_variable1, );
$entry_line1->g_pack;

my $label_two =
  $mw->new_label( -textvariable => \$label2, -font => "Courier 12 bold" );
$label_two->g_pack( -padx => 10, -pady => 10 );

my $button_one;
$button_one = $mw->new_button(
    -text    => "Find and Rename",
    -font    => "Courier 16 bold",
    -command => sub {
        $label2 = "Scanning";
        $count  = $entry_variable1;

        # print ("Count:  $count \n");
        parse();
        $label2 = "Scan Completed";
    },
);
$button_one->g_pack(
    -padx => 10,
    -pady => 10,
    -side => 'left'
);
my $button_two;
$button_two = $mw->new_button(
    -text    => "Exit",
    -font    => "Courier 18 bold",
    -command => sub {
        $label2 = "Exiting";
        Tkx::after( 2500, sub { $mw->g_destroy } );
    },
);
$button_two->g_pack(
    -padx => 10,
    -pady => 10,
    -side => 'right'
);

#  Self contained working message box left here for use.  Doesn't really make sense to use with above interface
#Tkx::tk___messageBox(
#	-parent => $mw,
#	-icon => "info",
#	-title => "Info Window Title",
#	-message => "Info Window Message!",
#);

Tkx::MainLoop();

exit 0;

#-----------------------------------------------------------------------
#
#  Subroutines
#
#-----------------------------------------------------------------------

sub parse {

#  Call the find routine and pass it the subroutine to execute against each file found
    @ARGV = (".") unless @ARGV;    # Start in current directory
    find( \&disguide, @ARGV );

}

sub disguide {

    $old_path = $File::Find::name;
    ( $base, $dir, $ext ) = fileparse( $old_path, '\..*' );    # Parse file name
    $old_file = $base . $ext;
    $CAP_ext  = $ext;
    $CAP_ext =~ tr/a-z/A-Z/;    #Convert extension to upper case

    if (   ( $CAP_ext eq ".JPG" )
        || ( $CAP_ext eq ".AVI" )
        || ( $CAP_ext eq ".CR2" )
        || ( $CAP_ext eq ".ORF" )
        || ( $CAP_ext eq ".MOV" ) )
    {

        if ( -f $old_file ) {

# Extract key EXIF data from media file, using EXIFTOL instead of Perl EXIF modules

        print("Extracting EXIF data for file: $old_file  \n");
        $make_line =
          `/users/carl/bin/exiftool.exe -Make $old_file`
          ;    # Use EXIFTOOL to determine camera make
print ("Make:  $make_line  \n");
        $model_line =
          `/users/carl/bin/exiftool.exe -Model $old_file`
          ;    # Use EXIFTOOL to determine camera model
print ("Model:  $model_line  \n");
        $date_line =
          `/users/carl/bin/exiftool.exe -CreateDate $old_file`
          ;    # Use EXIFTOOL to determine time photo was shot
        if ( length($make_line) == 0 ) {
            die("EXIF call for Make failed.  \n");
        }      # Test for failure with EXIFTOOL
        if ( length($model_line) == 0 ) {
            die("EXIF call for Model failed.  \n");
        }
        if ( length($date_line) == 0 ) {
            die("EXIF call for Date Time failed.  \n");
        }

# Perform date sanity checks, in case of camera dating errors, errors using EXIFTOOL or other problems
        $year =
          substr( $date_line, 34, 4 );   #Extract year number from original file
        if ( $year < 2001 ) { die("Date Error:  Year too low. \n"); }

        $current_year_calc =
          ( (localtime)[5] ) - 100;      #Determine year at script run time
        if ( $current_year_calc < 10 ) {
            $year_seq = "0" . "$current_year_calc";
        }
        else {
            $year_seq = "$current_year_calc";
        }
        $year_seq = $year_seq + 2000;

# print ("  Current Year:   $year_seq \n");  # For diagnostics in times of trouble

        if ( $year > $year_seq ) { die("Date Error:  Year beyond today. \n"); }

        ########
        #  Future improvement:  compare full current date to full timestamp date
        ########

        $month =
          substr( $date_line, 39, 2 );  #Extract month number from original file
        if ( $month > 12 ) { die("Date Error:  Month too high. \n"); }

        $day =
          substr( $date_line, 42, 2 );    #Extract day number from original file
        if ( $day > 31 ) { die("Date Error:  Day too high. \n"); }

       # print (" $date_line, = $year, = $month, =  $day  \n"); #For diagnostics

        $seq_string = "00000" . $count;   #Build long string of sequence counter
        $seq_offset =
          ( length($seq_string) - 5 );    #Shorten sequence counter string
        $sequence = substr( $seq_string, $seq_offset );

        # Create file name strings based on camera model identification
        if ( $make_line =~ /Canon/ ) {    #EXIF Data shows Canon camera
            if ( $model_line =~ /40D/ ) {    #EXIF Data shows Canon 40D camera
                $camera_indicator = "_40D_";
                $snew_filebase    =
                    $year . "_" . $month . "_" . $day
                  . $camera_indicator
                  . $sequence;               #Build new file name

            }
            elsif ( $model_line =~ /S3/ ) {    #EXIF Data shows Canon S3 camera
                $camera_indicator = "_S3IS_";
                $snew_filebase    =
                    $year . $month . $day
                  . $camera_indicator
                  . $sequence;                 #Build new file name
            }
        }
        elsif ( $make_line =~ /OLYMPUS/ ) {

            # $camera_indicator = "_OMD-EM1_";
            $camera_indicator = "_Stylus1S_";
            $snew_filebase    =
                $year . "_" . $month . "_" . $day
              . $camera_indicator
              . $sequence;                     #Build new file name
        }
        else {    #EXIF Data shows some other camera
            $camera_indicator = "_UNKNOWN_";
            $snew_filebase    =
                $year . $month . $day
              . $camera_indicator
              . $sequence;    #Build new file name
        }

        # Find specific image and video files and rename them
        # Find Canon raw image files
        $canon_raw_image_file = $base . ".CR2";
        if ( -f $canon_raw_image_file ) {
            $new_raw_image_filename =
              $snew_filebase . ".CR2";    #Build new file name
            print(
"Rename Canon raw files: $canon_raw_image_file, $new_raw_image_filename  \n"
            );
            rename( $canon_raw_image_file, $new_raw_image_filename )
              or die
"Can't rename $canon_raw_image_file to $new_raw_image_filename $! \n";
        }

        # Find Olympus raw image files
        $olympus_raw_image_file = $base . ".ORF";
        if ( -f $olympus_raw_image_file ) {
            $new_raw_image_filename =
              $snew_filebase . ".ORF";    #Build new file name
            print(
"Rename Olympus raw files: $olympus_raw_image_file, $new_raw_image_filename  \n"
            );
            rename( $olympus_raw_image_file, $new_raw_image_filename )
              or die
"Can't rename $canon_raw_image_file to $new_raw_image_filename $! \n";
        }

        # Find MOV movie files
        $movie_file = $base . ".MOV";
        if ( -f $movie_file ) {
            $new_movie_filename = $snew_filebase . ".MOV";  #Build new file name
            print("Rename MOV files: $movie_file, $new_movie_filename  \n");
            rename( $movie_file, $new_movie_filename )
              or die "Can't rename $movie_file to $new_movie_filename $! \n";
        }

        # Find AVI movie files
        $avi_file = $base . ".AVI";
        if ( -f $avi_file ) {
            $new_avi_filename = $snew_filebase . ".AVI";    #Build new file name
            print("Rename AVI files: $avi_file, $new_avi_filename  \n");
            rename( $avi_file, $new_avi_filename )
              or die "Can't rename $avi_file to $new_avi_filename $! \n";
        }

        # Find JPG files
        $jpg_file = $base . ".JPG";
        if ( -f $jpg_file ) {
            $new_jpg_filename = $snew_filebase . ".JPG";    #Build new file name
            print("Rename JPG files: $jpg_file, $new_jpg_filename  \n");
            rename( $jpg_file, $new_jpg_filename )
              or die "Can't rename $jpg_file to $new_jpg_filename $! \n";
        }

        $count = $count + 1;    #Increment file sequence counter
      }
    }			# End of main if block for supported file types
}			# End of subroutine

