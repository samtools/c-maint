TAG = none

tar:
	./mktarball ../bcftools $(TAG) -solo
	./mktarball ../htslib $(TAG)
	./mktarball ../samtools $(TAG) -solo

clean:
	-rm -f *.tar.bz2

.PHONY: clean tar
