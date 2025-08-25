#!/usr/bin/perl

#########                                 
# * *  *#                                 
#   ****#                                 
# *    *#                                 
#  *  **#                                 
# * *** #                                 
#****   #
#* *  * #
#  **** #
# ***  *#
#***  **#
#########

#use IO::Socket;
#our $sock = new IO::Socket::INET(
#		PeerAddr => '218.153.172.215',
#		PeerPort => '3194',
#		Protol => 'tcp',
#		);
#die "Could not create socket: $!\n" unless $sock; 

while (1) {
	our @current_board;
	our @new_board;
	our $width;
	our $len;
	our $generations;
	# read in new board
	read_board();
	print_current_board();

	# calculate next board
	for (my $i =0; $i < $generations; $i++) {
		calculate_new_board();
		copy_board();
		print_current_board();
	}

	# send next board
	print_new_board();
#	send_new_board();
}

sub copy_board() {
	for (my $i = 0; $i < $len; $i+=1) {
		for (my $j = 0; $j < $width; $j+=1) {
			$current_board[$i][$j] = $new_board[$i][$j];
		}
	}
}

sub read_board() {
	my $first=0;
	my $line_num = 0;
	while (1) {
		my $line = <STDIN> or die "disconnected";
		chomp $line;
		if ($line !~ /^#/) {
			print "$line\n";
			next;
		}

		if ($line =~ /###/ && $first == 0) {
			$first = 1;
			next;
		}

		if ($line =~ /###/ && $first == 1) {
			# found last
			$line = <STDIN> or die "disconnected";
			chomp $line;
			if ($line =~ /:(\d+)/) {
				print "generations: $1\n";
				$generations = $1;
			}
			return;
		}

		$line =~ s/#//g;
		$width = length($line);
		my @a = split //, $line;
#		foreach my $c (@a) {
#			print "$c";
#		}
#		print "\n";

		my $col = 0;
		foreach my $c (@a) {
			$current_board[$line_num][$col] = $c;
			$col+=1;
		}
#		push(@current_board, @a);
		$line_num+=1;
		$len = $line_num;
	}

		
}

sub print_current_board() {
	print "Received\n";
	print "#";
	for (my $j = 0; $j < $width; $j+=1) {
		print "#";
	}
	print "#";
	print "\n";
	for (my $i = 0; $i < $len; $i+=1) {
		print "#";
		for (my $j = 0; $j < $width; $j+=1) {
			print $current_board[$i][$j];
		}
		print "#";
		print "\n";
	}
	print "#";
	for (my $j = 0; $j < $width; $j+=1) {
		print "#";
	}
	print "#";
	print "\n";
}

sub print_new_board() {
	print "#";
	for (my $j = 0; $j < $width; $j+=1) {
		print "#";
	}
	print "#";
	print "\n";
	for (my $i = 0; $i < $len; $i+=1) {
		print "#";
		for (my $j = 0; $j < $width; $j+=1) {
			print $new_board[$i][$j];
		}
		print "#";
		print "\n";
	}
	print "#";
	for (my $j = 0; $j < $width; $j+=1) {
		print "#";
	}
	print "#";
	print "\n";
}

sub send_new_board() {
	print $sock "#";
	for (my $j = 0; $j < $width; $j+=1) {
		print $sock "#";
	}
	print $sock "#";
	print $sock "\n";
	for (my $i = 0; $i < $len; $i+=1) {
		print $sock "#";
		for (my $j = 0; $j < $width; $j+=1) {
			print $sock $new_board[$i][$j];
		}
		print $sock "#";
		print $sock "\n";
	}
	print $sock "#";
	for (my $j = 0; $j < $width; $j+=1) {
		print $sock "#";
	}
	print $sock "#";
	print $sock "\n";
}

sub calculate_new_board() {

	for (my $i = 0; $i < $len; $i+=1) {
		for (my $j = 0; $j < $width; $j+=1) {
			my $neighbors = 0;

			#NW
			if ($i-1>=0 && $j-1>=0 && $current_board[$i-1][$j-1] eq '*') {
				$neighbors+=1;
			}
			#N
			if ($i-1>=0 && $current_board[$i-1][$j] eq '*') {
				$neighbors+=1;
			}
			#NE
			if ($i-1>=0 && $j+1<=$width && $current_board[$i-1][$j+1] eq '*') {
				$neighbors+=1;
			}
			#W
			if ($j+1>=0 && $current_board[$i][$j+1] eq '*') {
				$neighbors+=1;
			}
			#SE
			if ($i+1<=$len && $j+1<=$width && $current_board[$i+1][$j+1] eq '*') {
				$neighbors+=1;
			}
			#S
			if ($i+1<=$len && $current_board[$i+1][$j] eq '*') {
				$neighbors+=1;
			}
			#SW
			if ($i+1<=$len && $j-1>=0 && $current_board[$i+1][$j-1] eq '*') {
				$neighbors+=1;
			}
			#W
			if ($j-1>=0 && $current_board[$i][$j-1] eq '*') {
				$neighbors+=1;
			}

#			print "$i,$j: $neighbors\n";

			if ($current_board[$i][$j] eq '*') {
				if ($neighbors == 0 || $neighbors == 1) {
					$new_board[$i][$j] = ' ';
				}
				if ($neighbors == 2 || $neighbors == 3) {
					$new_board[$i][$j] = '*';
				}
				if ($neighbors >= 4) {
					$new_board[$i][$j] = ' ';
				}
			} else {
				if ($neighbors == 3) {
					$new_board[$i][$j] = '*';
				} else {
					$new_board[$i][$j] = ' ';
				}
			}
		}
	}
}
