# -----------------------------------------
# Makefile – Phaser project builder
# -----------------------------------------

PROJECT = phaserdemo

PHASER_VERSION = 3.90.0

SRC_DIR    = src
DIST_DIR   = dist
WEB_DIR    = $(DIST_DIR)/web
OUTPUT_ZIP = $(PROJECT)-$(VERSION).html.zip

VERSION_FILE = .version
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

ci-version:
	@if [ -f metadata.json ]; then \
		VERSION=$$(jq -r '.version' metadata.json); \
	else \
		VERSION=$$(git rev-parse --short HEAD); \
	fi; \
	BRANCH=$$(git rev-parse --abbrev-ref HEAD); \
	if [ "$$BRANCH" != "main" ] && [ "$$BRANCH" != "master" ]; then \
		VERSION="dev-$$VERSION-$$BRANCH"; \
	fi; \
	echo $$VERSION > $(VERSION_FILE)

ci-export:
	@VERSION=$$(cat $(VERSION_FILE)); \
	$(MAKE) export VERSION=$$VERSION

ci-upload:
	@VERSION=$$(cat $(VERSION_FILE)); \
	FILE="$(PROJECT)-$$VERSION.html.zip"; \
	META_SRC="metadata.json"; \
	META_DST="$(PROJECT)-$$VERSION.metadata.json"; \
	cp $$META_SRC $$META_DST; \
	for f in $$FILE $$META_DST; do \
		curl -fsS -H "X-Update-Secret: $(UPDATE_SECRET)" \
			-F "file=@$$f" \
			"$(UPDATE_SERVER)/build/upload?name=$(PROJECT)&version=$$VERSION" || exit 1; \
	done

ci-publish:
	@VERSION=$$(cat $(VERSION_FILE)); \
	curl -fsS -X POST -H "X-Update-Secret: $(UPDATE_SECRET)" "$(UPDATE_SERVER)/build/publish?name=$(PROJECT)&platform=phaser&version=$$VERSION"

.PHONY: all build web serve export watch clean ci-version ci-export ci-upload ci-publish
