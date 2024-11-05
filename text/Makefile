.PHONY: all

IGK_PATH?=../../../igk/Build/

all: test.html test.pdf

test.html: concepts.tex Makefile
	${IGK_PATH}/igk --plugin ${IGK_PATH}/libigk-clang.dylib --lua-directory ${IGK_PATH}/../lua/ --lua-directory ../lua --file concepts.tex --pass begin-end --pass blank-is-paragraph --pass number-tables --pass clang-listing --pass html-xref --pass html-listings --pass html-headings --pass html-lists --pass html-em --pass html-boilerplate --pass clean-empty --pass html-label-id --pass HTMLOutputPass > test.html 

test.pdf: test.xml
	sile test.xml

test.xml: concepts.tex Makefile
	${IGK_PATH}/igk --plugin ${IGK_PATH}/libigk-clang.dylib --lua-directory ${IGK_PATH}/../lua/ --lua-directory ../lua --file concepts.tex --pass begin-end --pass blank-is-paragraph --pass number-tables --pass clang-listing --pass sile-listings --pass sile-paragraph --pass sile-keywords --pass sile-description-lists --pass sile-tables --pass sile-note --pass sile-xref --pass sile-boilerplate --pass clean-empty --pass XMLOutputPass > test.xml
