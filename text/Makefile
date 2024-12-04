.PHONY: all validate

IGK_PATH?=../../../igk/Build/

all: test.html test.pdf

SOURCES=\
	adding_a_new_board.tex \
	book.tex \
	compartments.tex \
	concepts.tex \
	core_rtos.tex \
	debugging_apis.tex \
	drivers.tex \
	language_extensions.tex \
	memory.tex \
	porting_from_bare_metal.tex \
	porting_from_freertos.tex \
	threads.tex


test.html: ${SOURCES} Makefile
	${IGK_PATH}/igk --plugin ${IGK_PATH}/libigk-clang.dylib --lua-directory ${IGK_PATH}/../lua/ --lua-directory ../lua --file book.tex --pass include --pass metadata --pass clean-empty --pass begin-end --pass blank-is-paragraph --pass autolabel --pass number-tables --pass clang-listing --pass html-lua --pass html-listings --pass html-lists --pass html-em --pass html-xref --pass html-keywords --pass html-admonitions --pass html-multipage 

test.pdf: test.xml
	sile test.xml
	#sile test.xml

test.xml: ${SOURCES} Makefile
	${IGK_PATH}/igk --plugin ${IGK_PATH}/libigk-clang.dylib --lua-directory ${IGK_PATH}/../lua/ --lua-directory ../lua --file book.tex --pass include --pass metadata --pass clean-empty --pass begin-end --pass blank-is-paragraph --pass autolabel --pass number-tables --pass clang-listing --pass sile-lua --pass sile-listings --pass sile-paragraph --pass sile-keywords --pass sile-description-lists --pass sile-tables --pass sile-note --pass sile-xref --pass sile-boilerplate --pass clean-empty --pass XMLOutputPass > test.xml

validate: test.html
	for I in *.html ; do vnu $$I ; done
