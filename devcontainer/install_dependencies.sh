echo | apt-get install -y software-properties-common
add-apt-repository -y ppa:sile-typesetter/sile
apt update
echo | apt install -y git git-lfs sile luarocks

git clone --recursive https://github.com/cheriot-platform/book
cd book/text/
luarocks --lua-version 5.1 --tree lua_modules install resilient.sile
 /igk/bin/igk --plugin /igk/lib/libigk-clang.so --plugin /igk/lib/libigk-treesitter.so --lua-directory /igk/share/igk-lua --lua-directory ../lua --file book.tex --pass include --pass if --pass fixme --pass metadata --pass clean-empty --pass begin-end --pass comment --pass blank-is-paragraph --pass autolabel --pass sile-admonitions --pass clang-listing --pass ts-listing --pass ts-inlines --pass sile-lua --pass sile-listings --pass sile-paragraph --pass sile-keywords --pass sile-description-lists --pass sile-tables --pass sile-figure --pass sile-note --pass sile-xref --pass sile-href --pass sile-boilerplate --pass clean-empty --pass pdf-ebook-cover --pass XMLOutputPass --config sile_packages="cheriot.listings;font-fallback;cheriot.indexer;cheriot.toyfloats;masters;background" --config output=sile > cheriot-programmers-guide.xml
sile cheriot-programmers-guide.xml
sile cheriot-programmers-guide.xml
sile cheriot-programmers-guide.xml
