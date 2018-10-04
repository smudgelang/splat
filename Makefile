.PHONY: smudge smear tests clean all

all: smudge smear

smear/libsmear.a:
	cd smear && make

smudge:
	cd smudge && make

smear: smear/libsmear.a

smudge-splat_%.deb:
	equivs-build splat-control

tests:
	cd test && make

clean:
	cd smear && make clean
	cd smudge && make clean
	cd doc/tutorial && make clean
	rm *.deb
