.PHONY: all validate html

IGK_PATH?=../../../igk/Build/

all: html cheriot-programmers-guide.pdf

SOURCES=\
	audit.tex \
	adding_a_new_board.tex \
	book.tex \
	compartments.tex \
	concepts.tex \
	core_rtos.tex \
	debugging_apis.tex \
	drivers.tex \
	getting_started.tex \
	language_extensions.tex \
	memory.tex \
	networking.tex \
	porting_from_bare_metal.tex \
	porting_from_freertos.tex \
	threads.tex


html: ${SOURCES} Makefile
	mkdir -p _site/figures
	cp book.css _site/
	cp figures/*.png _site/figures
	cp figures/*.jpg _site/figures
	cp figures/*.svg _site/figures
	${IGK_PATH}/igk --plugin ${IGK_PATH}/libigk-clang.dylib --plugin ${IGK_PATH}/libigk-treesitter.dylib --lua-directory ${IGK_PATH}/../lua/ --lua-directory ../lua --file book.tex --pass include --pass if --pass fixme --pass metadata --pass clean-empty --pass begin-end --pass comment --pass blank-is-paragraph --pass autolabel --pass clang-listing --pass ts-listing --pass number-tables --pass html-lua --pass html-listings --pass html-lists --pass html-em --pass html-xref --pass html-keywords --pass html-admonitions --pass html-multipage  --config output_directory=_site --config output=html

cheriot-programmers-guide.pdf: ${SOURCES} Makefile
	${IGK_PATH}/igk --plugin ${IGK_PATH}/libigk-clang.dylib --plugin ${IGK_PATH}/libigk-treesitter.dylib --lua-directory ${IGK_PATH}/../lua/ --lua-directory ../lua --file book.tex --pass include --pass if --pass fixme --pass metadata --pass clean-empty --pass begin-end --pass comment --pass blank-is-paragraph --pass autolabel --pass sile-admonitions --pass clang-listing --pass ts-listing --pass sile-lua --pass sile-listings --pass sile-paragraph --pass sile-keywords --pass sile-description-lists --pass sile-tables --pass sile-figure --pass sile-note --pass sile-xref --pass sile-boilerplate --pass clean-empty --pass XMLOutputPass --config sile_packages="cheriot.listings;font-fallback" --config output=sile > cheriot-programmers-guide.xml 
	./run_sile.sh cheriot-programmers-guide.xml

validate: html
	for I in *.html ; do vnu $$I ; done

clean:
	rm -rf _site
	rm -f cheriot-programmers-guide*
