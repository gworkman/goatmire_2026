TYPST ?= typst
FLAGS := --font-path fonts
OUT   := build/goatmire-2026.pdf
TUT   := build/badge-tutorial.pdf
SRC   := $(shell find . -name '*.typ' -not -path './build/*') $(shell find images -type f)

.PHONY: all watch open clean

all: $(OUT) $(TUT)

$(OUT): $(SRC)
	@mkdir -p build
	$(TYPST) compile $(FLAGS) main.typ $@

$(TUT): $(SRC)
	@mkdir -p build
	$(TYPST) compile $(FLAGS) tutorial.typ $@

watch:
	@mkdir -p build
	$(TYPST) watch $(FLAGS) main.typ $(OUT)

open: $(OUT)
	open $(OUT)

clean:
	rm -rf build
