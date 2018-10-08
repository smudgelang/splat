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
SPLAT_VERSION=$(shell grep "^Version" splat-control | cut -f 2 -d " ")
SPLAT_URL=https://github.com/smudgelang/splat
POUND=\\\#

.PHONY: smudge smear tests clean all \
		stage stage_zip stage_tgz package zip exe tgz deb

all: smear smudge package

smear:
	make -C smear package

smudge:
	make -C smudge package

stage:
	rm -rf $(SPLAT_RELEASE_STAGE_DIR)
	mkdir -p $(SPLAT_RELEASE_STAGE_DIR)
	cp LICENSE $(SPLAT_RELEASE_STAGE_DIR)
	cp README.md $(SPLAT_RELEASE_STAGE_DIR)

stage_zip: stage
	make -C smudge zip
	make -C smear zip
	cd $(SPLAT_RELEASE_STAGE_DIR) && \
	unzip ../../smudge/smudge-*-*.zip && \
	unzip ../../smear/libsmear-dev_*_$(PLATFORM).zip

stage_tgz: stage
	make -C smudge tgz
	make -C smear tgz
	cd $(SPLAT_RELEASE_STAGE_DIR) && \
	tar -xf ../../smudge/smudge-*-*.tgz && \
	tar -xf ../../smear/libsmear-dev_*_$(PLATFORM).tgz

package: $(foreach EXT,$(PKGEXT),$(PACKAGE)_$(SPLAT_VERSION)_$(PLATFORM).$(EXT))

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
	@echo $(POUND)define MyOutputDir    \"$(SPLAT_BUILD_DIR)\" >>$@
	@echo $(POUND)define MySetupDir     \"$(SPLAT_RELEASE_STAGE_DIR)\" >>$@
	cat $< >>$@

exe: $(PACKAGE)_$(SPLAT_VERSION)_$(PLATFORM).exe
$(PACKAGE)_$(SPLAT_VERSION)_windows.exe: $(SPLAT_BUILD_DIR)/setup.iss stage_zip
	ISCC /Q $(SMUDGE_BUILD_DIR_RAW)\setup.iss
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
	cd test && make

clean:
	cd smear && make clean
	cd smudge && make clean
	cd doc/tutorial && make clean
	rm -rf $(SPLAT_BUILD_DIR)
	rm -f *.deb *.tgz *.zip
