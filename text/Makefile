.PHONY: all validate html

IGK_PATH?=../../../igk/Build/
IGK_LIB_PATH?=../../../igk/Build/
IGK_LUA_PATH?=../../../igk/lua

all: html cheriot-programmers-guide.pdf cheriot-programmers-guide.print.pdf

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
	preface.tex \
	threads.tex

HTML_PASSES= \
	--pass include \
	--pass if \
	--pass fixme \
	--pass metadata \
	--pass clean-empty \
	--pass begin-end \
	--pass comment \
	--pass blank-is-paragraph \
	--pass review \
	--pass autolabel \
	--pass clang-listing \
	--pass ts-listing \
	--pass ts-inlines \
	--pass number-tables \
	--pass html-lua \
	--pass html-listings \
	--pass html-lists \
	--pass html-em \
	--pass html-xref \
	--pass html-keywords \
	--pass html-admonitions \
	--pass html-multipage 

PDF_PASSES= \
	--pass include \
	--pass if \
	--pass fixme \
	--pass metadata \
	--pass clean-empty \
	--pass begin-end \
	--pass comment \
	--pass review \
	--pass blank-is-paragraph \
	--pass autolabel \
	--pass sile-admonitions \
	--pass clang-listing \
	--pass ts-listing \
	--pass ts-inlines \
	--pass sile-lua \
	--pass sile-listings \
	--pass sile-paragraph \
	--pass sile-keywords \
	--pass sile-description-lists \
	--pass sile-tables \
	--pass sile-figure \
	--pass sile-note \
	--pass sile-xref \
	--pass sile-href \
	--pass sile-cleanup \
	--pass sile-boilerplate \
	--pass clean-empty \
	--pass pdf-ebook-cover \
	--pass XMLOutputPass

IGK_PLUGINS= \
	--plugin ${IGK_LIB_PATH}/libigk-clang.* --plugin ${IGK_LIB_PATH}/libigk-treesitter.* \
	--lua-directory ${IGK_LUA_PATH}/ --lua-directory ../lua

html: ${SOURCES} Makefile
	mkdir -p _site/figures
	cp book.css _site/
	cp figures/*.png _site/figures
	cp figures/*.jpg _site/figures
	cp -R figures/*.svg _site/figures
	${IGK_PATH}/igk --file book.tex ${IGK_PLUGINS} ${HTML_PASSES} --config output_directory=_site --config output=html --config 'DTD=<!DOCTYPE html>' --config language=en-GB

cheriot-programmers-guide.pdf: ${SOURCES} Makefile
	${IGK_PATH}/igk --file book.tex ${IGK_PLUGINS} ${PDF_PASSES} --config sile_packages="cheriot.listings;font-fallback;cheriot.indexer;cheriot.toyfloats;masters;background" --config output=sile > cheriot-programmers-guide.xml 
	./run_sile.sh cheriot-programmers-guide.xml
	./run_sile.sh cheriot-programmers-guide.xml

cheriot-programmers-guide.print.pdf: ${SOURCES} Makefile
	${IGK_PATH}/igk --file book.tex ${IGK_PLUGINS} ${PDF_PASSES} --config sile_packages="cheriot.listings;font-fallback;cheriot.indexer;cheriot.toyfloats;masters;background" --config output=sile --config print=true > cheriot-programmers-guide.print.xml 
	./run_sile.sh cheriot-programmers-guide.print.xml

cheriot-programmers-guide.print.mono.pdf: cheriot-programmers-guide.print.pdf
	gs  -sOutputFile=cheriot-programmers-guide.print.mono.pdf  -sDEVICE=pdfwrite  -sColorConversionStrategy=Gray  -dProcessColorModel=/DeviceGray  -dCompatibilityLevel=1.4  -dNOPAUSE  -dBATCH  cheriot-programmers-guide.print.pdf

validate: html
	for I in _site/*.html ; do vnu $$I ; done

clean:
	rm -rf _site
	rm -f cheriot-programmers-guide*
