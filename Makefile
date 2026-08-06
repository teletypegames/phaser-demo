# -----------------------------------------
# Makefile – Phaser project builder
# -----------------------------------------

PROJECT = phaserdemo

PHASER_VERSION = 3.90.0

SRC_DIR    = src
DIST_DIR   = dist
WEB_DIR    = $(DIST_DIR)/web
OUTPUT_ZIP = $(PROJECT)-$(VERSION).html.zip

PHASER_JS_URL  = https://cdn.jsdelivr.net/npm/phaser@$(PHASER_VERSION)/dist/phaser.min.js
INDEX_HTML_URL = https://git.teletypegames.org/tools/phaser-tools/raw/branch/master/web/index.html

all: build

build:
	@echo "==> Checking JS syntax"
	@for f in $(SRC_DIR)/*.js; do node --check $$f; done

web: build
	@mkdir -p $(WEB_DIR)
	@echo "==> Downloading Phaser $(PHASER_VERSION)"
	curl -sSL $(PHASER_JS_URL) -o $(WEB_DIR)/phaser.min.js
	@echo "==> Downloading index.html"
	curl -sSL $(INDEX_HTML_URL) -o $(WEB_DIR)/index.html
	@echo "==> Bundling game sources"
	cat $(SRC_DIR)/*.js > $(WEB_DIR)/game.js

serve: web
	@echo "==> Serving on http://localhost:8000"
	python3 -m http.server -d $(WEB_DIR) 8000

export: web
	@if [ -z "$(VERSION)" ]; then \
		echo "ERROR: VERSION not set!"; exit 1; \
	fi
	@echo "==> Packaging web build for $(VERSION)"
	cd $(WEB_DIR) && zip -r ../../$(OUTPUT_ZIP) .
	@echo "==> Cleaning temporary files"
	rm -rf $(WEB_DIR)

watch:
	fswatch -o $(SRC_DIR) | while read; do make build; done

clean:
	rm -rf $(DIST_DIR)

.PHONY: all build web serve export watch clean
