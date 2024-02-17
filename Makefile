
SOURCE_FILES := $(wildcard src/*.v)

TEST_BENCH_FILES := $(wildcard tb/*_tb.v)
TEST_BENCH := $(subst .v,,$(notdir $(TEST_BENCH_FILES)))
INCLUDE_FILES := $(wildcard inc/*.v)

RUN_TARGETS := $(addprefix run_, $(TEST_BENCH))

.PHONY : default run_all

default : compile run_all
compile : $(TEST_BENCH)
run_all : $(RUN_TARGETS)

$(TEST_BENCH) : $(SOURCE_FILES) $(TEST_BENCH_FILES) $(INCLUDE_FILES)
	@echo Compiling $@
	@iverilog -o $@ tb/$@.v $(filter-out $(INCLUDE_FILES), $(filter-out %_tb.v,$^)) -I inc/

clean:
	rm -f $(TEST_BENCH) $(TEST_BENCH:%=%.vcd)

$(RUN_TARGETS): run_%: %
	@vvp $^ -lxt
