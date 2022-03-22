#!/usr/bin/perl
#
# Convert GDEMU SD Card to MODE v1.0
# Written by Derek Pascarella (ateam)
#
# A utility to convert a GDEMU-formatted SD card to one suited for MODE.

# Include necessary modules.
use strict;
use Text::Wrap;

# Define column width for text-wrapping.
$Text::Wrap::columns = 72;

# Define input variables.
my $sd_path_source = $ARGV[0];

# Define/initialize variables.
my $disc_image_count = 0;
my $multi_disc_game_count = 0;
my $unknown_game_name_counter = 0;
my $sd_path_source_handler;
my $sd_game_folder_handler;
my $sd_image_type_check_handler;
my $sd_image_presence_check_handler;
my $sd_multi_disc_handler;
my $sd_subfolder;
my $sd_game_file;
my $game_name_handle;
my $game_name;
my $error;
my $proceed;
my $i;
my $disc_number;
my $gdi_filename;
my $gdi_track_filename;
my $gdi_data;
my $multi_disc_game_name;
my @gdi_toc;
my @multi_disc_game_files;
my @image_presence_game_files;
my %multi_disc_games;

# Path to source SD card is missing.
if(!defined $sd_path_source || $sd_path_source eq "")
{
	$error = "ERROR: Must specify source SD card path as first argument.";
	&show_error($error);
}
# Path to source SD card doesn't exist.
elsif(!-e $sd_path_source)
{
	$error = "ERROR: Source SD card path \"$sd_path_source\" does not exist.";
	&show_error($error);
}
# Path to source SD card is not readable.
elsif(!-R $sd_path_source)
{
	$error = "ERROR: Source SD card path \"$sd_path_source\" is not readable.";
	&show_error($error);
}

# Print program information.
print "Convert GDEMU SD Card to MODE v1.0\n";
print "Written by Derek Pascarella (ateam)\n\n";

# Print warning message and require user to confirm before proceeding.
print wrap("", "", "WARNING! This utility will move, rename, and delete files on the target SD card in order to conform to MODE's requirements. Please do not run this program against a copy of your daily-use GDEMU SD card. Instead, use a copy or backup.");
print "\n\nProceed with converting the GDEMU SD card? (Y/N) ";
chop($proceed = <STDIN>);

# If user does not wish to proceed, terminate program.
if(lc($proceed) ne "y")
{
	exit;
}

# Print status message.
print "\n> Creating \"DREAMCAST\" folder...\n\n";
mkdir($sd_path_source . "/DREAMCAST");
print "> Processing GDEMU SD card...\n\n";

# Open SD card path for reading.
opendir($sd_path_source_handler, $sd_path_source);

# Iterate through contents of SD card in alphanumeric order.
foreach $sd_subfolder (sort { 'numeric'; $a <=> $b }  readdir($sd_path_source_handler))
{
	# Skip "." and "..".
	next if($sd_subfolder =~ /^\.\.?/);
	
	# Skip all non-folders (i.e., files), like "GDEMU.INI".
	next if(!-d $sd_path_source . "/" . $sd_subfolder);
	
	# Skip folder "01" containing GDMenu.
	next if($sd_subfolder eq "01");

	# Skip newly created "DREAMCAST" folder.
	next if($sd_subfolder eq "DREAMCAST");

	# Open game folder containing disc image to detect disc image type.
	opendir($sd_image_presence_check_handler, $sd_path_source . "/" . $sd_subfolder);
	@image_presence_game_files = readdir($sd_image_presence_check_handler);
	closedir($sd_image_presence_check_handler);

	# Skip folders that don't contain a disc image.
	next if(!grep(/\.cdi/, @image_presence_game_files) && !grep(/\.gdi/, @image_presence_game_files));

	# Increase disc image count by one.
	$disc_image_count ++;

	# Remove folder "01" containing GDMenu.
	unlink glob($sd_path_source . "/01/*");
	rmdir($sd_path_source . "/01");

	# Remove GDEMU configuration file.
	unlink($sd_path_source . "/GDEMU.ini");

	# If "name.txt" exists for game, store name for current disc image.
	if(-e $sd_path_source . "/" . $sd_subfolder . "/name.txt")
	{
		# Open game name text file.
		open($game_name_handle, "<", $sd_path_source . "/" . $sd_subfolder . "/name.txt");
		$game_name = <$game_name_handle>;
		close($game_name_handle);

		# Remove illegal characters (:\/:*?"<>|) from filename, as well as extraneous whitespace.
		$game_name =~ s/:/ -/g;
		$game_name =~ s/([\\\/:*?"<>|])//g;
		$game_name =~ s/^\s+|\s+$//g;
		$game_name =~ s/ +/ /;
		$game_name =~ s/\s+/ /g;
	}
	# Otherwise, label it as unknown.
	else
	{
		# Increase unknown game name counter by one and store name.
		$unknown_game_name_counter ++;
		$game_name = "UNKNOWN $unknown_game_name_counter";
	}

	# Print current game.
	print "      Folder number: " . $sd_subfolder . "\n";
	print "          Game name: " . $game_name;

	# Remove text files from subfolder.
	unlink glob($sd_path_source . "/" . $sd_subfolder . "/*.txt");

	# If subfolder already exists with game name, process as multi-disc.
	if(-e $sd_path_source . "/DREAMCAST/" . $game_name || exists($multi_disc_games{$game_name}))
	{
		# Multi-disc game has already been encountered, so increase count by one.
		if(exists($multi_disc_games{$game_name}))
		{
			$multi_disc_games{$game_name} ++;

			# Rename current numbered subfolder according to game name and disc number.
			rename($sd_path_source . "/" . $sd_subfolder, $sd_path_source . "/DREAMCAST/" . $game_name . " - DISC " . $multi_disc_games{$game_name});
		}
		# Otherwise, start count at two.
		else
		{
			$multi_disc_games{$game_name} = 2;

			# Increase multi-disc game counter.
			$multi_disc_game_count ++;

			# Rename current numbered subfolder according to game name and disc number.
			rename($sd_path_source . "/" . $sd_subfolder, $sd_path_source . "/DREAMCAST/" . $game_name . " - DISC " . $multi_disc_games{$game_name});
			
			# Rename original disc one subfolder.
			rename($sd_path_source . "/DREAMCAST/" . $game_name, $sd_path_source . "/DREAMCAST/" . $game_name . " - DISC 1");
		}

		# Print disc number.
		print " (DISC " . $multi_disc_games{$game_name} . ")";
	}
	# Otherwise, rename subfolder per game name.
	else
	{
		rename($sd_path_source . "/" . $sd_subfolder, $sd_path_source . "/DREAMCAST/" . $game_name);
	}

	print "\n\n";
}

# Close SD card path.
closedir($sd_path_source_handler);

# If disc images were processed, begin grouping multi-disc games into the same folder.
if($multi_disc_game_count > 0)
{
	# Print status message.
	print "> Initial conversion complete!\n\n";
	print "> Waiting five seconds before grouping multi-disc games...\n";
	sleep 5;

	# Open newly created "DREAMCAST" folder for reading.
	opendir($sd_path_source_handler, $sd_path_source . "/DREAMCAST");

	# Iterate through "DREAMCAST" folder in alphanumeric order.
	foreach $sd_subfolder (sort(readdir($sd_path_source_handler)))
	{
		# Skip "." and "..".
		next if($sd_subfolder =~ /^\.\.?/);

		# Skip non-multi-disc games.
		next if($sd_subfolder !~ / - DISC /);

		# Store disc number of current game.
		$disc_number = substr($sd_subfolder, -1);

		# Open game folder containing disc image to detect disc image type.
		opendir($sd_image_type_check_handler, $sd_path_source . "/DREAMCAST/" . $sd_subfolder);
		@multi_disc_game_files = readdir($sd_image_type_check_handler);
		closedir($sd_image_type_check_handler);

		# Current game is a CDI.
		if(grep /\.cdi/, @multi_disc_game_files)
		{
			# Iterate through game files to find CDI.
			foreach(@multi_disc_game_files)
			{
				# Skip "." and "..".
				next if($_ =~ /^\.\.?/);

				# CDI found, store filename.
				if($_ =~ /\.cdi/)
				{
					$sd_game_file = $_;
				}
			}

			# Rename CDI according to disc number.
			rename($sd_path_source . "/DREAMCAST/" . $sd_subfolder . "/" . $sd_game_file, $sd_path_source . "/DREAMCAST/" . $sd_subfolder . "/disc" . $disc_number . "_" . $sd_game_file);
		}
		# Current game is a GDI.
		elsif(grep /\.gdi/, @multi_disc_game_files)
		{
			# Open game folder containing disc image.
			opendir($sd_game_folder_handler, $sd_path_source . "/DREAMCAST/" . $sd_subfolder);

			# Iterate through game folder in alphanumeric order.
			foreach $sd_game_file (sort(readdir($sd_game_folder_handler)))
			{
				# Skip "." and "..".
				next if($sd_game_file =~ /^\.\.?/);

				# Store GDI table of contents filename when encountered.
				if($sd_game_file =~ /\.gdi/i)
				{
					$gdi_filename = "disc" . $disc_number . "_" . $sd_game_file;
				}

				# Rename file.
				rename($sd_path_source . "/DREAMCAST/" . $sd_subfolder . "/" . $sd_game_file, $sd_path_source . "/DREAMCAST/" . $sd_subfolder . "/disc" . $disc_number . "_" . $sd_game_file);
			}

			# Store contents of GDI table of contents.
			@gdi_toc = &read_file_as_array($sd_path_source . "/DREAMCAST/" . $sd_subfolder . "/" . $gdi_filename);

			# Iterate through each GDI track entry in the table of contents and rename it according to disc number.
			for($i = 1; $i < scalar(@gdi_toc); $i ++)
			{
				$gdi_track_filename = (split /\s+/, $gdi_toc[$i])[4];
				$gdi_toc[$i] =~ s/$gdi_track_filename/disc$disc_number\_$gdi_track_filename/g;
			}

			# Flatten GDI table of contents.
			$gdi_data = join("\n", @gdi_toc);
			$gdi_data .= "\n";

			# Write new GDI table of contents to file.
			&write_file($sd_path_source . "/DREAMCAST/" . $sd_subfolder . "/" . $gdi_filename, $gdi_data);

			# Close game folder.
			closedir($sd_game_folder_handler);	
		}
	}

	# Close "DREAMCAST" folder.
	closedir($sd_path_source_handler);

	print "\n";

	# Iterate through each key of the multi-disc game hash to process single-folder grouping.
	foreach $multi_disc_game_name (keys %multi_disc_games)
	{
		# Print current game.
		print "    Multi-disc game: " . $multi_disc_game_name . " (" . $multi_disc_games{$multi_disc_game_name} . " DISCS)\n\n";

		# Create new base folder for multi-disc game.
		mkdir($sd_path_source . "/DREAMCAST/" . $multi_disc_game_name);

		# Iterate through each disc number.
		for(1 ... $multi_disc_games{$multi_disc_game_name})
		{
			# Open "DISC X" labeled game folder.
			opendir($sd_multi_disc_handler, $sd_path_source . "/DREAMCAST/" . $multi_disc_game_name . " - DISC " . $_);
			
			# Iterate through game folder in alphanumeric order.
			foreach $sd_game_file (sort(readdir($sd_multi_disc_handler)))
			{
				# Skip "." and "..".
				next if($sd_game_file =~ /^\.\.?/);

				# Rename file.
				rename($sd_path_source . "/DREAMCAST/" . $multi_disc_game_name . " - DISC " . $_ . "/" . $sd_game_file, $sd_path_source . "/DREAMCAST/" . $multi_disc_game_name . "/" . $sd_game_file);
			}

			# Delete "DISC X" game folder.
			rmdir($sd_path_source . "/DREAMCAST/" . $multi_disc_game_name . " - DISC " . $_);

			# Close game folder.
			closedir($sd_multi_disc_handler);
		}
	}
}

# Print status message.
print "> SD card conversion complete!\n\n";

# Print final status message.
print "Disc images processed: " . $disc_image_count . "\n";
print "Multi-disc game count: " . $multi_disc_game_count . "\n";
print "   Unknown game count: " . $unknown_game_name_counter . "\n";

# Subroutine to throw a specified exception.
#
# 1st parameter - Error message with which to throw exception.
sub show_error
{
	my $error = $_[0];

	die "Convert GDEMU SD Card to MODE v1.0\nWritten by Derek Pascarella (ateam)\n\n$error\n\nUSAGE: gdemu_to_mode <PATH_TO_SD_CARD>\n";
}

# Subroutine to read a specified file.
#
# 1st parameter - File to read.
sub read_file
{
	my ($filename) = @_;

	open my $in, '<:encoding(UTF-8)', $filename or die "Could not open '$filename' for reading $!";
	local $/ = undef;
	my $all = <$in>;
	close $in;

	return $all;
}

# Subroutine to read a specified file.
#
# 1st parameter - File to read.
sub read_file_as_array
{
	my ($filename) = @_;

	open my $in, '<:encoding(UTF-8)', $filename or die "Could not open '$filename' for reading $!";
	chomp(my @lines = <$in>);
	close $in;

	return @lines;
}

# Subroutine to write data to a specified file.
#
# 1st parameter - File to write.
# 2nd parameter - Data to write.
sub write_file
{
	my ($filename, $content) = @_;

	open my $out, '>:encoding(UTF-8)', $filename or die "Could not open '$filename' for writing $!";;
	print $out $content;
	close $out;

	return;
}