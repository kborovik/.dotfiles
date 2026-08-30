.SILENT:
.EXPORT_ALL_VARIABLES:
.PHONY: default help init base tools zed claude grok opencode pgsql ssh
.PHONY: fish fish-completions gpg git vim gitui glamour
.PHONY: git-credentials-load git-credentials-save commit prompt ssh-save ssh-encrypt gpg-encrypt

MAKEFLAGS += --no-builtin-rules --no-builtin-variables

SHELL := /bin/sh
PATH := /opt/homebrew/bin:$(PATH)
TERM := xterm-256color

default: help

###############################################################################
# Colors and Helpers
###############################################################################

blue := $$(tput setaf 4)
green := $$(tput setaf 2)
yellow := $$(tput setaf 3)
reset := $$(tput sgr0)

define header
echo "$(blue)==> $(1) <==$(reset)"
endef

help:
	echo "$(blue)Usage: $(green)make [target]$(reset)"
	echo "$(blue)Targets:$(reset)"
	awk 'BEGIN {FS = ":.*?## "; sort_cmd = "sort"} /^[a-zA-Z0-9_-]+:.*?## / \
	{ printf "  \033[33m%-25s\033[0m %s\n", $$1, $$2 | sort_cmd; } \
	END {close(sort_cmd)}' $(MAKEFILE_LIST)

###############################################################################
# Init: Install Homebrew
###############################################################################

brew_bin := /opt/homebrew/bin/brew

$(brew_bin):
	$(call header,Homebrew - Install)
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

init: $(brew_bin) ## Install Homebrew

###############################################################################
# Base: Core Development Tools
###############################################################################

coreutils_bin := /opt/homebrew/Cellar/coreutils
sed_bin := /opt/homebrew/opt/gnu-sed/libexec/gnubin/sed
gmake_bin := /opt/homebrew/opt/make/libexec/gnubin/make
jq_bin := /opt/homebrew/bin/jq
pass_bin := /opt/homebrew/bin/pass
gh_bin := /opt/homebrew/bin/gh
fish_bin := /opt/homebrew/bin/fish
gpg_bin := /opt/homebrew/bin/gpg
pinentry_mac_bin := /opt/homebrew/bin/pinentry-mac
git_bin := /opt/homebrew/bin/git
riff_bin := /opt/homebrew/bin/riff
vim_bin := /opt/homebrew/bin/vim
gitui_bin := /opt/homebrew/bin/gitui
glow_bin := /opt/homebrew/bin/glow
bat_bin := /opt/homebrew/bin/bat
tree_bin := /opt/homebrew/bin/tree

$(coreutils_bin):
	$(call header,coreutils - Install)
	brew install coreutils

$(sed_bin):
	$(call header,gnu-sed - Install)
	brew install gnu-sed

$(gmake_bin):
	$(call header,gnu-make - Install)
	brew install make

$(jq_bin):
	$(call header,jq - Install)
	brew install jq

$(gpg_bin):
	$(call header,gnupg - Install)
	brew install gnupg

$(pinentry_mac_bin):
	$(call header,pinentry-mac - Install)
	brew install pinentry-mac

$(pass_bin): | $(gpg_bin)
	$(call header,pass - Install)
	brew install pass

$(gh_bin):
	$(call header,gh - Install)
	brew install gh

$(fish_bin):
	$(call header,fish - Install)
	brew install fish

$(git_bin): $(riff_bin)
	$(call header,git - Install)
	brew install git

$(riff_bin):
	$(call header,riff - Install)
	brew install riff

$(vim_bin):
	$(call header,vim - Install)
	brew install vim

$(gitui_bin):
	$(call header,gitui - Install)
	brew install gitui

$(glow_bin):
	$(call header,glow - Install)
	brew install glow

$(bat_bin):
	$(call header,bat - Install)
	brew install bat

$(tree_bin):
	$(call header,tree - Install)
	brew install tree

tools: $(coreutils_bin) $(sed_bin) $(gmake_bin) $(jq_bin) $(pass_bin) $(gh_bin) $(tree_bin)

base: tools $(fish_bin) gpg $(git_bin) $(riff_bin) $(vim_bin) $(gitui_bin) $(glow_bin) $(bat_bin) ## Install base tools and configs
	$(call header,Base - Configure)
	/bin/ln -fs $(CURDIR)/pathenv $(HOME)/.pathenv
	/bin/ln -fs $(CURDIR)/zshenv $(HOME)/.zshenv
	/bin/ln -fs $(CURDIR)/bashenv $(HOME)/.bashenv
	/bin/ln -fs $(CURDIR)/digrc $(HOME)/.digrc
	rm -f $(HOME)/.config/fish && /bin/ln -fs $(CURDIR)/fish $(HOME)/.config/fish
	/bin/ln -fs $(CURDIR)/gitconfig $(HOME)/.gitconfig
	rm -f $(HOME)/.vim && /bin/ln -fs $(CURDIR)/vim $(HOME)/.vim
	/bin/ln -fs $(CURDIR)/vim/vimrc $(HOME)/.vimrc
	mkdir -p $(HOME)/.config/gitui
	/bin/ln -fs $(CURDIR)/gitui/theme.ron $(HOME)/.config/gitui/theme.ron
	/bin/ln -fs $(CURDIR)/gitui/key_bindings.ron $(HOME)/.config/gitui/key_bindings.ron
	bat cache --build >/dev/null
	mkdir -p $(HOME)/Library/Preferences/glow
	/bin/ln -fs $(CURDIR)/glow/glow.yml $(HOME)/Library/Preferences/glow/glow.yml
	/bin/ln -fs $(CURDIR)/glamour/glamour-custom.json $(HOME)/Library/Preferences/glow/glamour-custom.json
	$(MAKE) fish-completions

# bat/glow/uv: Homebrew vendor completions. grok/wrangler: generate when installed.
fish-completions: ## Generate optional fish completions (grok, wrangler)
	$(call header,fish - Completions)
	if command -v grok >/dev/null 2>&1; then \
		grok completions fish > $(CURDIR)/fish/completions/grok.fish; \
		echo "  grok.fish regenerated"; \
	else \
		rm -f $(CURDIR)/fish/completions/grok.fish; \
		echo "  grok not installed — skipped"; \
	fi
	if command -v wrangler >/dev/null 2>&1; then \
		wrangler completions fish > $(CURDIR)/fish/completions/wrangler.fish; \
		echo "  wrangler.fish regenerated"; \
	else \
		rm -f $(CURDIR)/fish/completions/wrangler.fish; \
		echo "  wrangler not installed — skipped"; \
	fi

###############################################################################
# Zed Editor
###############################################################################

zed_bin := /opt/homebrew/bin/zed
zed_dir := $(HOME)/.config/zed

$(zed_bin):
	$(call header,Zed - Install)
	brew install --cask zed

zed: $(zed_bin) ## Install Zed editor
	$(call header,Zed - Configure)
	mkdir -p $(zed_dir)
	/bin/ln -fs $(CURDIR)/zed/settings.json $(zed_dir)/settings.json
	/bin/ln -fs $(CURDIR)/zed/keymap.json $(zed_dir)/keymap.json

###############################################################################
# Claude Code
###############################################################################

claude_bin := $(HOME)/.local/bin/claude
claude_dir := $(HOME)/.claude
node_bin := /opt/homebrew/bin/node
rg_bin := /opt/homebrew/bin/rg

$(node_bin):
	$(call header,node - Install)
	brew install node

$(rg_bin):
	$(call header,ripgrep - Install)
	brew install ripgrep

$(claude_bin): $(node_bin) $(rg_bin)
	$(call header,Claude Code - Install)
	curl -fsSL https://claude.ai/install.sh | bash

claude: $(claude_bin) ## Install Claude Code
	$(call header,Claude Code - Configure)
	mkdir -p $(claude_dir) $(claude_dir)/skills
	/bin/ln -fs $(CURDIR)/claude/settings.json $(claude_dir)/settings.json
	/bin/ln -fs $(CURDIR)/claude/statusline-command.sh $(claude_dir)/statusline-command.sh
	rm -f $(claude_dir)/skills/rephrase && /bin/ln -fs $(CURDIR)/claude/skills/rephrase $(claude_dir)/skills/rephrase

###############################################################################
# Grok Build
###############################################################################

grok_bin := $(HOME)/.local/bin/grok
grok_dir := $(HOME)/.grok

$(grok_bin):
	$(call header,Grok - Install)
	curl -fsSL https://x.ai/cli/install.sh | bash

grok: $(grok_bin) ## Install Grok Build CLI
	$(call header,Grok - Configure)
	mkdir -p $(grok_dir)
	/bin/ln -fs $(CURDIR)/grok/config.toml $(grok_dir)/config.toml

###############################################################################
# opencode
###############################################################################

opencode_bin := $(HOME)/.opencode/bin/opencode
opencode_dir := $(HOME)/.opencode
opencode_config_dir := $(HOME)/.config/opencode

$(opencode_bin): $(node_bin) $(rg_bin)
	$(call header,opencode - Install)
	curl -fsSL https://opencode.ai/install | bash

opencode: $(opencode_bin) ## Install opencode
	$(call header,opencode - Configure)
	mkdir -p $(opencode_dir)/skills $(opencode_dir)/commands $(opencode_dir)/scripts $(opencode_config_dir)
	rm -f $(opencode_config_dir)/opencode.json
	/bin/ln -fs $(CURDIR)/opencode/opencode.jsonc $(opencode_config_dir)/opencode.jsonc
	for d in $(CURDIR)/opencode/skills/*/; do \
		name=$$(basename $$d); \
		rm -rf $(opencode_dir)/skills/$$name; \
		/bin/ln -fs $$d $(opencode_dir)/skills/$$name; \
	done
	for f in $(CURDIR)/opencode/commands/*.md; do \
		name=$$(basename $$f); \
		rm -f $(opencode_dir)/commands/$$name; \
		/bin/ln -fs $$f $(opencode_dir)/commands/$$name; \
	done
	for f in $(CURDIR)/opencode/scripts/*; do \
		name=$$(basename $$f); \
		rm -f $(opencode_dir)/scripts/$$name; \
		/bin/ln -fs $$f $(opencode_dir)/scripts/$$name; \
	done

###############################################################################
# PostgreSQL
###############################################################################

pg_bin := /opt/homebrew/bin/postgres
pgcli_bin := /opt/homebrew/bin/pgcli
pg_data := /opt/homebrew/var/postgresql@18

$(pg_bin):
	$(call header,PostgreSQL 18 - Install)
	brew install postgresql@18

$(pgcli_bin):
	$(call header,pgcli - Install)
	brew install pgcli

pgsql: $(pg_bin) $(pgcli_bin) ## Install PostgreSQL 18
	$(call header,PostgreSQL - Configure)
	mkdir -p $(pg_data)/conf.d
	/bin/ln -fs $(CURDIR)/pgsql/performance.conf $(pg_data)/conf.d/performance.conf
	mkdir -p $(HOME)/.config/pgcli
	/bin/ln -fs $(CURDIR)/pgsql/pgcli.conf $(HOME)/.config/pgcli/config
	grep -q "include_dir = 'conf.d'" $(pg_data)/postgresql.conf || echo "include_dir = 'conf.d'" >> $(pg_data)/postgresql.conf
	brew services restart postgresql@18

###############################################################################
# GnuPG
###############################################################################

gpg_dir := $(HOME)/.gnupg
gpg_pass_entry := gpg/github@lab5.ca

gpg: $(gpg_bin) $(pinentry_mac_bin) ## Install GnuPG + pinentry-mac and link configs
	$(call header,GnuPG - Configure)
	mkdir -p $(gpg_dir) && chmod 700 $(gpg_dir)
	/bin/ln -fs $(CURDIR)/gnupg/gpg.conf $(gpg_dir)/gpg.conf
	/bin/ln -fs $(CURDIR)/gnupg/gpg-agent.conf $(gpg_dir)/gpg-agent.conf
	gpgconf --kill gpg-agent

gpg-encrypt: $(pass_bin) $(gpg_bin) ## Check all on-disk GPG private keys are passphrase-encrypted
	$(call header,GPG - Check key encryption)
	unenc=0; \
	for f in $(gpg_dir)/private-keys-v1.d/*.key; do \
		[ -f "$$f" ] || continue; \
		kg=$$(basename "$$f" .key); \
		head=$$(head -c 200 "$$f"); \
		case "$$head" in \
			*protected-private-key*) echo "encrypted:   $$kg" ;; \
			*shadowed-private-key*)  echo "on-card:     $$kg" ;; \
			*private-key*)           echo "UNENCRYPTED: $$kg"; unenc=$$((unenc+1)) ;; \
			*)                       echo "unknown:     $$kg" ;; \
		esac; \
	done; \
	if [ $$unenc -eq 0 ]; then exit 0; fi; \
	pass $(gpg_pass_entry) >/dev/null 2>&1 || { echo ""; echo "ERROR: pass $(gpg_pass_entry) not set. Run: pass insert -e $(gpg_pass_entry)"; exit 1; }; \
	echo ""; \
	echo "To encrypt (paste passphrase from: pass $(gpg_pass_entry)):"; \
	echo "  gpg -K --with-keygrip      # find the FPR whose keygrip matches an UNENCRYPTED line above"; \
	echo "  gpg --edit-key <FPR>"; \
	echo "  gpg> passwd"; \
	echo "  gpg> save"; \
	exit 1

###############################################################################
# SSH
###############################################################################

ssh_dir := $(HOME)/.ssh
ssh_id_ed25519 := $(ssh_dir)/id_ed25519
ssh_id_rsa := $(ssh_dir)/id_rsa

$(ssh_dir):
	mkdir -p $(@) && chmod 700 $(@)

ssh: $(pass_bin) | $(ssh_dir) ## Configure SSH keys
	$(call header,SSH - Decrypt config)
	rm -f $(ssh_dir)/config && gpg -d $(CURDIR)/ssh/config.gpg > $(ssh_dir)/config && chmod 600 $(ssh_dir)/config
	test -f $(ssh_id_ed25519) || (pass ssh/id_ed25519 > $(ssh_id_ed25519) && chmod 600 $(ssh_id_ed25519) && ssh-keygen -y -f $(ssh_id_ed25519) > $(ssh_id_ed25519).pub && chmod 644 $(ssh_id_ed25519).pub)
	test -f $(ssh_id_rsa) || (pass ssh/id_rsa > $(ssh_id_rsa) && chmod 600 $(ssh_id_rsa) && ssh-keygen -y -f $(ssh_id_rsa) > $(ssh_id_rsa).pub && chmod 644 $(ssh_id_rsa).pub)
	$(MAKE) ssh-encrypt

ssh-encrypt: $(pass_bin) | $(ssh_dir) ## Add passphrase (from pass ssh/passphrase) to any unencrypted SSH private keys
	$(call header,SSH - Encrypt keys)
	pp=$$(pass ssh/passphrase); \
	for k in $$(grep -l "^-----BEGIN.*PRIVATE KEY-----" $(ssh_dir)/* 2>/dev/null); do \
		if ssh-keygen -y -P "" -f $$k >/dev/null 2>&1; then \
			echo "encrypting $$k"; \
			ssh-keygen -o -a 100 -p -P "" -N "$$pp" -f $$k >/dev/null; \
		else \
			echo "already encrypted: $$k"; \
		fi; \
	done

ssh-save: ## Re-encrypt ~/.ssh/config to repo
	$(call header,SSH - Encrypt config)
	gpg -er E4AFCA7FBB19FC029D519A524AEBB5178D5E96C1 -o $(CURDIR)/ssh/config.gpg $(ssh_dir)/config

###############################################################################
# Prompt
###############################################################################

prompt:
	echo -n "$(blue)Continue? (yes/no)$(reset)"
	read -p ": " answer && [ "$$answer" = "yes" ] || exit 1
