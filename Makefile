all: check

# NOTE: The checks below are rudimentary, just to filter away the most
# blatant issues. More diligent ones are in nut-website:nut-ddl.py parser.
check: check-filename-structure check-content-markup

html: index.html

index.html: .DUMMY
	[ -s ../Makefile ] && [ -x ../tools/nut-ddl.py ] # error out if not building along with nut-website
	D="`pwd`" && D="`basename "$$D"`" && [ -n "$$D" ] || D="ddl" ; \
	cd .. && $(MAKE) $(MAKE_FLAGS) $(AM_FLAGS) "$$D/index.html"

check-filename-structure:
	LANG=C; LC_ALL=C; TZ=UTC; \
	export LANG LC_ALL TZ ; \
	( find . -name '*.dev*' -o -name '*.nds*' | grep -E -v '\.(dev|nds)\.txt$$' | sort -n | while IFS='' read F ; do \
		MASK="`basename "$$F" | sed 's,^\(..*\)__\(..*\)__\(..*\)__\([0-9]..*\)__\([0-9][0-9]*\)\.\(dev\|nds\),MFG__MOD__DRV__NUTVER__REPNUM,'`" \
		&& [ "$$MASK" = "MFG__MOD__DRV__NUTVER__REPNUM" ] \
		&& echo "FILENAME OK: $$F" \
		|| { echo "FILENAME STRUCTURE FAILED: $$F ; EXPECTED:" >&2; \
			echo "    <manufacturer>__<model>__<driver_name>__<NUT_version>__<report_number>.{dev,nds}" >&2 ; \
			exit 1; } ; \
	done )

check-content-markup:
	LANG=C; LC_ALL=C; TZ=UTC; \
	export LANG LC_ALL TZ ; \
	find . -type f -name '*.dev' | ( \
		echo "`date -u`: Sanity-checking the *.dev files..."; \
		FAILED=""; \
		PASSED=""; \
		while read F ; do \
			egrep -v '^( *\#.*|.*:.*)$$' "$$F" | egrep -v '^$$' && echo "^^^ $$F" && FAILED="$$FAILED $$F" && continue; \
			PASSED="$$PASSED $$F"; \
		done; \
		if [ -n "$$FAILED" ]; then echo "`date -u`: FAILED sanity-check in following file(s) : $$FAILED" >&2; exit 1; fi; \
		echo "`date -u`: OK : All *.dev files have passed the basic sanity check : $$PASSED"; \
		exit 0; \
	)

.DUMMY:
