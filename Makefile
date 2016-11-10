SRC := ./src
DIST := ./dist
REQUIRED := node-sass browser-sync imagemin-cli svgo postcss-cli autoprefixer csso

help:
	@echo
	@echo "Available commands:"
	@echo "make setup     Installing the necessary npm packages"
	@echo "make clean     Removing \"dist\" directory"
	@echo "make build     Building the project into \"dist\" directory"
	@echo "make dev       Running node-sass (on watch mode) and browser-sync to ease the developing process"
	@echo

setup:
	@echo "Installing required packages..."
	@npm install -g $(REQUIRED)
	@echo "All packages have been successfully installed"

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
		postcss --use autoprefixer --autoprefixer.browsers "> 1%, last 2 versions" | \
		csso -o $(DIST)/css/style.css
	@echo "Done"
	@echo

build-js:
	@echo -n "Copying JS files... $0"
	@cp -r $(SRC)/js $(DIST)
	@echo "Done"
	@echo

build-assets:
	@echo "Minifying images..."
	@mkdir $(DIST)/images
	@imagemin $(SRC)/images/{*.jpg,*.png} -o $(DIST)/images
	@svgo --disable=removeUselessDefs --disable=cleanupIDs -f $(SRC)/images -o $(DIST)/images
	@echo "Done"
	@echo
	@echo -n "Copying fonts... $0"
	@cp -r $(SRC)/fonts $(DIST)
	@echo "Done"
	@echo

watch:
	@node-sass $(SRC)/css/style.scss $(SRC)/css/style.css --source-map true
	@node-sass $(SRC)/css/style.scss -wo $(SRC)/css/ --source-map true &

dev: watch
	browser-sync start --server "$(SRC)" --directory --files="$(SRC)/css/style.css, $(SRC)/*.html, $(SRC)/js/*.js"
