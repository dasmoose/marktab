########################################################################
# tools
########################################################################

CC = gcc
YACC = bison
LEX = flex
AR = ar

########################################################################
# flags
########################################################################

# cflags
DEBUG = -g
ERROR = -Wall -Wextra -Werror -Wno-unused-parameter -Wno-unused-function
PEDANTIC = -pedantic -pedantic-errors
STANDARD = -std=gnu99
OPTIMIZATION = -O3
CFLAGS = $(DEBUG) $(ERROR) $(PEDANTIC) $(STANDARD) $(OPTIMIZATION)

ARFLAGS = rcs
YFLAGS = -vyd
LFLAGS =

########################################################################
# files
########################################################################

# Source Directories
SRC_DIR = src
INCLUDE_DIR = include
LIB_DIR = lib
EXAMPLES_DIR = examples

# Test Directories
RCOMP_DIR = spec/rcomp
CHECK_DIR = spec/check

# Sources
LIBMT_SRCS = $(wildcard $(SRC_DIR)/*.c)

# Objects
LIBMT_OBJS = $(addprefix $(SRC_DIR)/,mt_parser.o mt_lexer.o) $(LIBMT_SRCS:.c=.o)

########################################################################
# targets
########################################################################

all: libmt

libmt: $(LIB_DIR)/libmt.a

# Library Target
$(LIB_DIR)/libmt.a: $(LIBMT_OBJS)
	$(AR) $(ARFLAGS) $@ $(LIBMT_OBJS)

# Parser Target
$(SRC_DIR)/mt_parser.o: $(SRC_DIR)/marktab.y
	$(YACC) $(YFLAGS) $< -o $(SRC_DIR)/mt_parser.c
	$(CC) $(CFLAGS) -c $(SRC_DIR)/mt_parser.c -o $@
	@rm $(SRC_DIR)/mt_parser.c

# Lexer Target
$(SRC_DIR)/mt_lexer.o: $(SRC_DIR)/marktab.l
	$(LEX) $(LFLAGS) -o $(SRC_DIR)/mt_lexer.c $<
	$(CC) $(CFLAGS) -c $(SRC_DIR)/mt_lexer.c -o $@
	@rm $(SRC_DIR)/mt_lexer.c

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Test Targets
test: rebuild check_test

check_test:
	make -C $(CHECK_DIR) rebuild

# Example Targets
examples: libmt
	make -C $(EXAMPLES_DIR)

# Clean Targets
clean: clean_build clean_test clean_examples

clean_build:
	rm -f $(addprefix $(SRC_DIR)/,*.o mt_lexer.* mt_parser.*)
	rm -f $(LIB_DIR)/libmt.a

clean_test:
	make -C $(CHECK_DIR) clean

clean_examples:
	make -C $(EXAMPLES_DIR) clean

rebuild: clean all

.PHONY: clean test
