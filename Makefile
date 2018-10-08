ifeq ($(OS),Windows_NT)
PKGEXT=zip
PLATFORM=windows
else
PKGEXT=tgz deb
PLATFORM=$(shell dpkg --print-architecture)
endif
PACKAGE=smudge-platform
SPLAT_BUILD_DIR=build
SPLAT_RELEASE_SUBDIR=$(PACKAGE)
SPLAT_RELEASE_STAGE_DIR=$(SPLAT_BUILD_DIR)/$(SPLAT_RELEASE_SUBDIR)
SPLAT_DOC_STAGE_DIR=smudge-doc/tutorial
SPLAT_VERSION=$(shell grep "^Version" splat-control | cut -f 2 -d " ")
SPLAT_URL=https://github.com/smudgelang/splat
POUND=\\\#

.PHONY: smudge smear tests clean all \
		stage stage_zip stage_tgz package zip exe tgz deb doc

all: smear smudge package

smear:
	$(MAKE) -C smear package

smudge:
	$(MAKE) -C smudge package

stage: $(SPLAT_DOC_STAGE_DIR)
	rm -rf $(SPLAT_RELEASE_STAGE_DIR)
	mkdir -p $(SPLAT_RELEASE_STAGE_DIR)
	cp CHANGES $(SPLAT_RELEASE_STAGE_DIR)
	cp LICENSE $(SPLAT_RELEASE_STAGE_DIR)
	cp README.md $(SPLAT_RELEASE_STAGE_DIR)
	cp -r $(SPLAT_DOC_STAGE_DIR) $(SPLAT_RELEASE_STAGE_DIR)

stage_zip: stage
	$(MAKE) -C smudge zip
	$(MAKE) -C smear zip
	cd $(SPLAT_RELEASE_STAGE_DIR) && \
	unzip ../../smudge/smudge-*-*.zip && \
	unzip ../../smear/libsmear-dev_*_$(PLATFORM).zip

stage_tgz: stage
	$(MAKE) -C smudge tgz
	$(MAKE) -C smear tgz
	cd $(SPLAT_RELEASE_STAGE_DIR) && \
	tar -xf ../../smudge/smudge-*-*.tgz && \
	tar -xf ../../smear/libsmear-dev_*_$(PLATFORM).tgz

package: $(foreach EXT,$(PKGEXT),$(PACKAGE)_$(SPLAT_VERSION)_$(PLATFORM).$(EXT))

$(SPLAT_DOC_STAGE_DIR): smudge
	rm -rf $(SPLAT_DOC_STAGE_DIR)
	mkdir -p $(SPLAT_DOC_STAGE_DIR)
	cp doc/tutorial/*.smudge $(SPLAT_DOC_STAGE_DIR)
	cp doc/tutorial/*.c $(SPLAT_DOC_STAGE_DIR)
	cp doc/tutorial/Makefile $(SPLAT_DOC_STAGE_DIR)
	$(MAKE) -C doc/tutorial pinball-tutorial.pdf
	cp doc/tutorial/pinball-tutorial.pdf $(SPLAT_DOC_STAGE_DIR)

zip: $(PACKAGE)_$(SPLAT_VERSION)_$(PLATFORM).zip
$(PACKAGE)_$(SPLAT_VERSION)_$(PLATFORM).zip: stage_zip
	cd $(SPLAT_BUILD_DIR) && \
	if type zip >/dev/null 2>&1; then \
	    zip -r $@ $(SPLAT_RELEASE_SUBDIR); \
	elif type 7z >/dev/null 2>&1; then \
	    7z a $@ $(SPLAT_RELEASE_SUBDIR); \
	fi
	mv $(SPLAT_BUILD_DIR)/$@ .

$(SPLAT_BUILD_DIR)/setup.iss: setup.iss.in
	mkdir -p $(SPLAT_BUILD_DIR)
	@echo $(POUND)define MyAppName      \"Smudge Platform\" > $@
	@echo $(POUND)define MyAppVersion   \"$(SPLAT_VERSION)\" >>$@
	@echo $(POUND)define MyAppURL       \"$(SPLAT_URL)\" >>$@
	@echo $(POUND)define MyOutputDir    \".\" >>$@
	@echo $(POUND)define MySetupDir     \"$(SPLAT_RELEASE_SUBDIR)\" >>$@
	cat $< >>$@

exe: $(PACKAGE)_$(SPLAT_VERSION)_$(PLATFORM).exe
$(PACKAGE)_$(SPLAT_VERSION)_windows.exe: $(SPLAT_BUILD_DIR)/setup.iss stage_zip
	cd $(SPLAT_BUILD_DIR) && \
	tail -n +1 $(SPLAT_RELEASE_SUBDIR)/LICENSE \
	           $(SPLAT_RELEASE_SUBDIR)/smudge/LICENSE \
	           $(SPLAT_RELEASE_SUBDIR)/smear/LICENSE > LICENSE
	ISCC /Q $(SPLAT_BUILD_DIR)\setup.iss
	mv $(SPLAT_BUILD_DIR)/$@ .

tgz: $(PACKAGE)_$(SPLAT_VERSION)_$(PLATFORM).tgz
$(PACKAGE)_$(SPLAT_VERSION)_$(PLATFORM).tgz: stage_tgz
	cd $(SPLAT_BUILD_DIR) && \
	fakeroot tar -czf $@ $(SPLAT_RELEASE_SUBDIR)
	mv $(SPLAT_BUILD_DIR)/$@ .

deb: $(PACKAGE)_$(SPLAT_VERSION)_$(PLATFORM).deb
$(PACKAGE)_$(SPLAT_VERSION)_$(PLATFORM).deb:
	equivs-build splat-control

tests:
	$(MAKE) -C test

clean:
	$(MAKE) -C smear clean
	$(MAKE) -C smudge clean
	$(MAKE) -C doc/tutorial clean
	rm -rf $(SPLAT_BUILD_DIR)
	rm -f *.deb *.tgz *.exe *.zip
	rm -rf $(SPLAT_DOC_STAGE_DIR)
