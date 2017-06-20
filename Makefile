PATH := node_modules/.bin:$(PATH)
SHELL := env PATH=$(PATH) /bin/bash

SRC := ./src
DIST := ./dist

help:
	@echo
	@echo "Available commands:"
	@echo "make setup     Install necessary npm packages"
	@echo "make clean     Remove \"dist\" directory"
	@echo "make build     Build the project into \"dist\" directory"
	@echo "make dev       Run node-sass (on watch mode) and browser-sync to ease the developing process"
	@echo

setup:
	@echo -n "Installing required packages... $0"
	@npm install &>/dev/null
	@echo "Done"

clean:
	@echo -n "Cleaning the \"dist\" directory... $0"
	@-rm -rf $(DIST)
	@echo "Done"
	@echo

build: clean build-start build-html build-css build-js build-assets
	@echo "Build completed"

build-start:
	@echo "Starting build tasks..."
	@echo
	@mkdir $(DIST)

build-html:
	@echo -n "Copying HTML files... $0"
	@cp $(SRC)/*.html $(DIST)
	@echo "Done"
	@echo

build-css:
	@echo -n "Compiling SCSS files... $0"
	@mkdir $(DIST)/css
	@node-sass $(SRC)/css/style.scss | \
		postcss --no-map --use autoprefixer --autoprefixer.browsers "> 1%, last 2 versions" 2>/dev/null | \
		csso -o $(DIST)/css/style.css &>/dev/null
	@echo "Done"
	@echo

build-js:
	@echo -n "Copying JS files... $0"
	@cp -r $(SRC)/js $(DIST)
	@echo "Done"
	@echo

build-assets:
	@echo -n "Minifying images... $0"
	@mkdir $(DIST)/images
	@imagemin $(SRC)/images/{*.jpg,*.png} -o $(DIST)/images &>/dev/null
	@svgo --disable=removeUselessDefs --disable=cleanupIDs -f $(SRC)/images -o $(DIST)/images &>/dev/null
	@echo "Done"
	@echo
	@echo -n "Copying fonts... $0"
	@cp -r $(SRC)/fonts $(DIST)
	@echo "Done"
	@echo

show:
	@browser-sync start --server "$(DIST)" --directory

watch:
	@node-sass $(SRC)/css/style.scss $(SRC)/css/style.css --source-map true
	@node-sass $(SRC)/css/style.scss -wo $(SRC)/css/ --source-map true &

dev: watch
	@browser-sync start --server "$(SRC)" --directory --files="$(SRC)/css/style.css, $(SRC)/*.html, $(SRC)/js/*.js"
