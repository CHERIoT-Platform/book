.PHONY: all validate html

IGK_PATH?=../../../igk/Build/

all: html cheriot-programmers-guide.pdf

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


html: ${SOURCES} Makefile
	mkdir -p _site
	cp book.css _site/
	${IGK_PATH}/igk --plugin ${IGK_PATH}/libigk-clang.dylib --lua-directory ${IGK_PATH}/../lua/ --lua-directory ../lua --file book.tex --pass include --pass fixme --pass metadata --pass clean-empty --pass begin-end --pass comment --pass blank-is-paragraph --pass autolabel --pass clang-listing --pass number-tables --pass html-lua --pass html-listings --pass html-lists --pass html-em --pass html-xref --pass html-keywords --pass html-admonitions --pass html-multipage  --config output_directory=_site

cheriot-programmers-guide.pdf: ${SOURCES} Makefile
	${IGK_PATH}/igk --plugin ${IGK_PATH}/libigk-clang.dylib --lua-directory ${IGK_PATH}/../lua/ --lua-directory ../lua --file book.tex --pass include --pass fixme --pass metadata --pass clean-empty --pass begin-end --pass comment --pass blank-is-paragraph --pass autolabel --pass sile-admonitions --pass clang-listing --pass sile-lua --pass sile-listings --pass sile-paragraph --pass sile-keywords --pass sile-description-lists --pass sile-tables --pass sile-note --pass sile-xref --pass sile-boilerplate --pass clean-empty --pass XMLOutputPass --config sile_packages=cheriot.listings > cheriot-programmers-guide.xml 
	sile cheriot-programmers-guide.xml

validate: html
	for I in *.html ; do vnu $$I ; done

clean:
	rm -rf _site
	rm -f cheriot-programmers-guide*
