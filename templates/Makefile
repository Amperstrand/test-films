# Film make-targets — copy into your project
#
# Fill every <<PLACEHOLDER>>. Make is the menu; the registry file is
# the source of truth CI also reads (docs/09-make-and-ci.md).
# This skeleton assumes:
#   <<RUNNER>>    = your test runner invocation (pytest-based or
#                   script) honoring --scenario/---film-dir/--narration
#   <<RENDERER>>  = generates scene list + reel from a run dir
#   <<CHECKER>>   = validates films (quotes, honesty, overlays)
#   <<PUBLISHER>> = publishes blobs + index events
#   provider.sh   = prints can-publish for the current environment
#                   (exit 0 = yes)

SCENARIO   ?= S0-happy-path
FILM_DIR   ?= films/$(SCENARIO)
RUN_ID     ?= $(shell date -u +%Y%m%dT%H%M%SZ)
PUBLISH_OK ?= $(shell ./scripts/provider.sh can-publish >/dev/null 2>&1 && echo 0 || echo 1)

.PHONY: film-list film-record film-cut film-check film-publish film-clean

help: ## Show this menu
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-16s %s\n", $$1, $$2}'

film-list: ## List filmed scenarios and their latest runs
	@ls -1 films/ 2>/dev/null || echo "no films yet"

film-record: ## Run a scenario with narration + capture
	<<RUNNER>> --scenario $(SCENARIO) --film-dir $(FILM_DIR)/$(RUN_ID) \
		--narration --video-on-failure
	@echo "run banked: $(FILM_DIR)/$(RUN_ID)"

film-cut: ## Generate scene list + reel from the latest run
	<<RENDERER>> --film-dir $(FILM_DIR)/$(RUN_ID)

film-check: ## Validate films (quotes, honesty, overlays)
	<<CHECKER>> --film-dir $(FILM_DIR)

film-publish: film-check ## Publish blobs + index (privacy-gated)
	@if [ "$(PUBLISH_OK)" != "0" ]; then \
		echo "publish disabled for this environment"; exit 1; fi
	<<PUBLISHER>> --film-dir $(FILM_DIR)/$(RUN_ID)

film-clean: ## Drop generated reels (KEEP raw footage + manifests)
	find $(FILM_DIR) -name index.html -delete
	find $(FILM_DIR) -name scenes.yaml -delete
