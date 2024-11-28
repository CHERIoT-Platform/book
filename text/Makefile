.PHONY: all validate

IGK_PATH?=../../../igk/Build/

all: test.html test.pdf

SOURCES=concepts.tex core_rtos.tex

test.html: ${SOURCES} Makefile
	${IGK_PATH}/igk --plugin ${IGK_PATH}/libigk-clang.dylib --lua-directory ${IGK_PATH}/../lua/ --lua-directory ../lua --file book.tex --pass include --pass clean-empty --pass begin-end --pass blank-is-paragraph --pass number-tables --pass clang-listing --pass html-lua --pass html-xref --pass html-listings --pass html-headings --pass html-lists --pass html-em --pass html-boilerplate --pass clean-empty --pass html-label-id --pass HTMLOutputPass > test.html 

test.pdf: test.xml
	sile test.xml
	sile test.xml

test.xml: ${SOURCES} Makefile
	${IGK_PATH}/igk --plugin ${IGK_PATH}/libigk-clang.dylib --lua-directory ${IGK_PATH}/../lua/ --lua-directory ../lua --file book.tex --pass include --pass clean-empty --pass begin-end --pass blank-is-paragraph --pass number-tables --pass clang-listing --pass sile-lua --pass sile-listings --pass sile-paragraph --pass sile-keywords --pass sile-description-lists --pass sile-tables --pass sile-note --pass sile-xref --pass sile-boilerplate --pass clean-empty --pass XMLOutputPass > test.xml

validate: test.html
	vnu test.html
