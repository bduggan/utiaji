test:
	PGDATABASE=test prove -Ilib -v -r --exec=perl6 t/

clean:
	find . -name .precomp | xargs rm -rf
