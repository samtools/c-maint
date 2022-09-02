include release_settings
TAR = .tar.bz2
TAG = $(version)
HTSTAG = $(if $(htslib_version),$(htslib_version),$(TAG))
SAMTAG = $(if $(samtools_version),$(samtools_version),$(TAG))
BCFTAG = $(if $(bcftools_version),$(bcftools_version),$(TAG))
PREFIX_DIR = ..

# Hack to get rid of the quote marks in the $(packages) variable.
PACKAGES_ := $(shell echo $(packages))

tar: $(PACKAGES_)

htslib: htslib-$(HTSTAG)$(TAR)

samtools: samtools-$(SAMTAG)$(TAR)

bcftools: bcftools-$(BCFTAG)$(TAR)

samtools-$(SAMTAG)$(TAR): samtools-$(SAMTAG)-solo$(TAR) htslib-$(HTSTAG)$(TAR)
	./addhtslib $@ $^ $(HTSTAG)

bcftools-$(BCFTAG)$(TAR): bcftools-$(BCFTAG)-solo$(TAR) htslib-$(HTSTAG)$(TAR)
	./addhtslib $@ $^ $(HTSTAG)

htslib-$(HTSTAG)$(TAR):
	./mktarball $(PREFIX_DIR)/htslib $(HTSTAG)

samtools-$(SAMTAG)-solo$(TAR):
	./mktarball $(PREFIX_DIR)/samtools $(SAMTAG) -solo

bcftools-$(BCFTAG)-solo$(TAR):
	./mktarball $(PREFIX_DIR)/bcftools $(BCFTAG) -solo

.PRECIOUS: samtools-$(SAMTAG)-solo$(TAR) bcftools-$(BCFTAG)-solo$(TAR)

clean:
	-rm -f *.tar.bz2

.PHONY: clean tar samtools bcftools htslib
