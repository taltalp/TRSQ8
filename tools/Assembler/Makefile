PYTHON := python

.PHONY: test

ASM := assembler.py
TRSQ := test.trsq

test: prom.v
	diff prom.v counter.v

prom.v: $(ASM) $(TRSQ)
	$(PYTHON) $^
