# Auto-discovers every folder containing a docker-compose.yaml.
# Add a new stack by creating stack-name/docker-compose.yaml + stack-name/.env
# -- no edits needed here.
STACKS := $(patsubst %/,%,$(dir $(wildcard */docker-compose.yaml)))

# Maps a make target name to the actual docker compose subcommand.
define compose_args
$(if $(filter up,$(1)),up -d,$(if $(filter logs,$(1)),logs -f,$(1)))
endef

.PHONY: up down restart ps logs stacks $(STACKS)

## make stacks -> list what was discovered
stacks:
	@echo $(STACKS)

up down restart ps logs:
	@stack="$(word 2,$(MAKECMDGOALS))"; \
	if [ -n "$$stack" ] && ! echo " $(STACKS) " | grep -q " $$stack "; then \
		echo "Unknown stack: $$stack"; \
		echo "Available: $(STACKS)"; \
		exit 1; \
	fi; \
	if [ "$@" = "logs" ] && [ -z "$$stack" ]; then \
		echo "logs needs a single stack (following multiple at once would just hang on the first): make logs <stack>"; \
		exit 1; \
	fi; \
	targets="$${stack:-$(STACKS)}"; \
	for s in $$targets; do \
		echo "==> $$s ($@)"; \
		docker compose -f $$s/docker-compose.yaml --env-file $$s/.env $(call compose_args,$@); \
	done

# Swallows the stack name as a no-op target so "make up media" doesn't
# make complain about "media" being an unknown goal.
$(STACKS):
	@:
