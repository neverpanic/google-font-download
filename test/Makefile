TESTS=eot svg ttf woff woff2 fonts-with-spaces multiple-fonts format-param output-param font-weight font-style
TUT=../../google-font-download

# tests use bashisms, avoid failures on systems where dash is used
# to simplify debugging failing test cases, use -x
SHELL := bash

.PHONY: test $(TESTS)

all:
	$(MAKE) -k test

test: $(TESTS)

V := @

# EOT starts with a header; the actual magicNumber is at offset 34 into the
# file and is 2 byte with a value of 0x504c (xxd only supports little endian
# with -ps!)
eot:
	$(V)echo "---> Testing $@"
	$(V)mkdir -p $@ && (cd $@ && $(TUT) -f $@ "Ubuntu" && [ "$$(xxd -s 34 -l 2 -ps Ubuntu.$@)" == "4c50" ]); ret=$$?; rm -rf $@ && exit $$ret
	$(V)echo "     OK"

svg:
	$(V)echo "---> Testing $@"
	$(V)mkdir -p $@ && (cd $@ && $(TUT) -f $@ "Ubuntu" && [ "$$(file --mime-type Ubuntu.$@ | cut -d " " -f 2)" == "image/svg+xml" ]); ret=$$?; rm -rf $@ && exit $$ret
	$(V)echo "     OK"

ttf:
	$(V)echo "---> Testing $@"
	$(V)mkdir -p $@ && (cd $@ && $(TUT) -f $@ "Ubuntu" && [ "$$(xxd -l 5 -ps Ubuntu.$@)" == "0001000000" ]); ret=$$?; rm -rf $@ && exit $$ret
	$(V)echo "     OK"

# WOFF starts with "wOFF" in ASCII, which happens to be 77 4f 46 46
woff:
	$(V)echo "---> Testing $@"
	$(V)mkdir -p $@ && (cd $@ && $(TUT) -f $@ "Ubuntu" && [ "$$(xxd -l 4 -ps Ubuntu.$@)" == "774f4646" ]); ret=$$?; rm -rf $@ && exit $$ret
	$(V)echo "     OK"

# WOFF2 starts with "wOF2" in ASCII, which happens to be 77 4f 46 32
woff2:
	$(V)echo "---> Testing $@"
	$(V)mkdir -p $@ && (cd $@ && $(TUT) -f $@ "Ubuntu" && [ "$$(xxd -l 4 -ps Ubuntu.$@)" == "774f4632" ]); ret=$$?; rm -rf $@ && exit $$ret
	$(V)echo "     OK"

fonts-with-spaces:
	$(V)echo "---> Testing font names with spaces"
	$(V)mkdir -p $@ && (cd $@ && $(TUT) -f woff "Open Sans" && [ -f "Open_Sans.woff" ]); ret=$$?; rm -rf $@ && exit $$ret
	$(V)echo "     OK"

multiple-fonts:
	$(V)echo "---> Testing downloading multiple fonts"
	$(V)mkdir -p $@ && (cd $@ && $(TUT) -f woff "Ubuntu" "Lora" && [ -f "Ubuntu.woff" ] && [ -f "Lora.woff" ]); ret=$$?; rm -rf $@ && exit $$ret
	$(V)echo "     OK"

format-param:
	$(V)echo "---> Testing that -f works as expected"
	$(V)mkdir -p $@ && (cd $@ && $(TUT) -f woff "Lora" && [ -f "Lora.woff" ] && [ ! -f "Lora.ttf" ]); ret=$$?; rm -rf $@ && exit $$ret
	$(V)echo "     OK"

output-param:
	$(V)echo "---> Testing that -o works as expected"
	$(V)mkdir -p $@ && (cd $@ && $(TUT) -f woff -o "other.css" "Lora" && [ -f "other.css" ] && [ ! -f "font.css" ]); ret=$$?; rm -rf $@ && exit $$ret
	$(V)echo "     OK"

font-weight:
	$(V)echo "---> Testing font weight support"
	$(V)mkdir -p $@ && (cd $@ && $(TUT) -f woff "Ubuntu:300" && grep "font-weight: 300;" "font.css" >/dev/null); ret=$$?; rm -rf $@ && exit $$ret
	$(V)echo "     OK"

font-style:
	$(V)echo "---> Testing font style support"
	$(V)mkdir -p $@ && (cd $@ && $(TUT) -f woff "Ubuntu:700italic" && grep "font-style: italic;" "font.css" >/dev/null); ret=$$?; rm -rf $@ && exit $$ret
	$(V)echo "     OK"
