TAR = .tar.bz2
TAG = none

tar: htslib-$(TAG)$(TAR) bcftools-$(TAG)$(TAR) samtools-$(TAG)$(TAR)

%-$(TAG)$(TAR): %-$(TAG)-solo$(TAR) htslib-$(TAG)$(TAR)
	./addhtslib $@ $^ $(TAG)

htslib-$(TAG)$(TAR):
	./mktarball ../rel/htslib $(TAG)

%-$(TAG)-solo$(TAR):
	./mktarball ../rel/$* $(TAG) -solo

.PRECIOUS: %-$(TAG)-solo$(TAR)

clean:
	-rm -f *.tar.bz2

.PHONY: clean tar
