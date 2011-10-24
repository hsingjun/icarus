w
#!usr/bin/perl
#use warnings;

#Project: JL01
#Function: find where each read is trimmed

#my $rawfl  = "C:\\hsingjun.Graduate\\datapool\\P3kRawReads";
#my $trimfl = "C:\\hsingjun.Graduate\\datapool\\P3kTrimAdaptor";
my $rawfl  = $ARGV[0];
my $trimfl = $ARGV[1];

my @rawreadsfl = ();
my @trimedreadsfl = ();
getfiles($rawfl, \@rawreadsfl);
getfiles($trimfl,\@trimedreadsfl);

open (OUT,">P3k.trimpos")||die "$!";
my %trimedreads = ();
my %rawreads  = ();
my @fastq_class = ();

my $posindicator = 0;
my $scannedRawReads = 0;
my $scannedTrimmedReads = 0;

readFastq($trimedreadsfl[0],\%trimedreads);
print "reading $trimedreadsfl[0] ... finished\n";
shift @trimedreadsfl;

foreach my $raw(@rawreadsfl)
{
	#$posindicator = 0;
	open (RW,"$raw")||die "$!";
	while(<RW>)
	{
		s/\s+$//;
		$posindicator ++;
		push @fastq_class, $_;
		if ($posindicator == 4)
		{
			if ($trimedreads{$fastq_class[0]} ne '') # The read is in .trime file
			{
				if ($trimedreads{$fastq_class[0]} ne $fastq_class[1]) # it is trimed
				{
					#$fastq_class[1] =~ m/$trimedreads{$fastq_class[0]}/;
					#if (pos($_) > 0)
					#{
					$_ = $fastq_class[1];
					while(m/$trimedreads{$fastq_class[0]}/g) 
					{
						my $cutpos =  pos $_;
						my @aread = split(//,$fastq_class[1]);
						my $firsthalf = join('',@aread[0..$cutpos-1]);
						$cutpos ++;
						my $secondhalf = join('',@aread[$cutpos-1..$#aread]);						
						
						#print OUT "$fastq_class[0]\t$fastq_class[1]\t$trimedreads{$fastq_class[0]}:$cutpos\n";
						print OUT "$fastq_class[0]\t$firsthalf-$secondhalf\t$trimedreads{$fastq_class[0]}:$cutpos\n";
					}
				}
				else # untrimmed
				{
					my $trimp = length($fastq_class[1])+1;
					print OUT "$fastq_class[0]\t$fastq_class[1]\t$trimedreads{$fastq_class[0]}\t$trimp\n";
				}
				
				delete $trimedreads{$fastq_class[0]};
				$scannedTrimmedReads ++;
				if ( (my $hsize = keys %trimedreads ) == 0)
				{
					if ($#trimedreadsfl ne -1)
					{
						readFastq($trimedreadsfl[0],\%trimedreads);
						print "reading $trimedreadsfl[0] ... finished\n";
						shift @trimedreadsfl;
					}
					else
					{
						print "!!!! trimed reads are all finished\n";
					}
				}
			}
			$posindicator = 0;
			@fastq_class = ();
			$scannedRawReads ++;
			}
		}
	close RW;
		
}

close OUT;

open(OUT,">stat")||die "$!";

print OUT "scannedRawReads\t$scannedRawReads\nscannedTrimmedReads\t$scannedTrimmedReads\n";

close OUT;

sub readFastq
{
	#return hash for each read.
	#Only id and sequence
	
	my $file = shift;
	my $array = shift;
	my @fastqclass = ();
	my $indicator = 0;
	open (IN,"$file")||die "$!";
	while(<IN>)
	{
		s/\s+$//;
		push @fastqclass, $_;
		$indicator ++;
		if ($indicator == 4)
		{
			$$array{$fastqclass[0]} = $fastqclass[1];
			$indicator = 0;
			@fastqclass = ();
		}
	}
	close IN;
}


sub getfiles
{
	my $dir = shift;
	my $files = shift;
	
	my @array = glob("$dir\/*");
	foreach my $item (@array)
	{
		if (-f $item)
		{
			push @$files, $item;
		}
	}
	
}
