.PHONY: all syntax-check shellcheck test

TARGET=google-font-download

all: syntax-check shellcheck

syntax-check:
	bash -n $(TARGET)

shellcheck:
	shellcheck $(TARGET)

test:
	$(MAKE) -C test
