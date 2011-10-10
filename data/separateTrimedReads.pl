#!usr/bin/perl 
#project: JL01
#input : trimed reads, removing linker.read length:40
#output: two files, one containing reads less than 35 bp, other more than 35 bp

use warnings;

my $infile = $ARGV[0];#trimed reads, in fastq format
my $outfile = $infile;
$outfile =~ s/trimed$/reads/;

my $untrimfl = $infile;
$untrimfl =~ s/trimed$/untrim/;

open (IN,"$infile")||die "$!";
open (OUT,">$outfile")||die "$!";
open (UN,">$untrimfl")||die "$!";

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
                if (length($aRead[1]) < 35)
                {
		    $trimedReads ++;
		    print OUT "$aRead[0]\n$aRead[1]\n$aRead[2]\n$aRead[3]\n";
                }
		else
		{
		    print UN "$aRead[0]\n$aRead[1]\n$aRead[2]\n$aRead[3]\n";
		}
                $num = 0;
                @aRead = ();
        }

}
print "$infile\t$trimedReads\n";
close IN;
close OUT;
close UN;
