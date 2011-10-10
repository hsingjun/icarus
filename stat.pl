#!usr/bin/perl 
use warnings;

my $infile = $ARGV[0];
my $outfile = $infile;
$outfile =~ s/trimed/reads/;

open (IN,"$infile")||die "$!";
open (OUT,">$outfile")||die "$!";


my @line = ();
my $num = 0;
my @aRead = ();
my $trimedReads = 0;


while(<IN>)
{
	s/\s+$//;
	push @aRead, $_;
	$num ++;
	if ($num == 4)
	{
		if (length($aRead[1]) < 40)
		{
			$trimedReads ++;
			print OUT "$aRead[0]\n$aRead[1]\n$aRead[2]\n$aRead[3]\n";
		}
		$num = 0;
		@aRead = ();
	}

}
print "$infile\t$trimedReads\n";
close IN;
