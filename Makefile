TAR = .tar.bz2
TAG = none
HTSTAG = $(TAG)

tar: htslib-$(HTSTAG)$(TAR) bcftools-$(TAG)$(TAR) samtools-$(TAG)$(TAR)

%-$(TAG)$(TAR): %-$(TAG)-solo$(TAR) htslib-$(HTSTAG)$(TAR)
	./addhtslib $@ $^ $(HTSTAG)

htslib-$(HTSTAG)$(TAR):
	./mktarball ../htslib $(HTSTAG)

%-$(TAG)-solo$(TAR):
	./mktarball ../$* $(TAG) -solo

.PRECIOUS: %-$(TAG)-solo$(TAR)

clean:
	-rm -f *.tar.bz2

.PHONY: clean tar
