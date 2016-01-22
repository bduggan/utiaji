test:
	PGDATABASE=test PERL6LIB=lib prove -v -r --exec=perl6 t/

