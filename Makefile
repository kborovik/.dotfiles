.SILENT:
.EXPORT_ALL_VARIABLES:
.PHONY: default help init base tools zed claude pgsql ssh
.PHONY: fish gpg git vim gitui glamour
.PHONY: git-credentials-load git-credentials-save commit prompt ssh-save

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

base: tools $(fish_bin) $(gpg_bin) $(git_bin) $(riff_bin) $(vim_bin) $(gitui_bin) $(glow_bin) $(bat_bin) ## Install base tools and configs
	$(call header,Base - Configure)
	/bin/ln -fs $(CURDIR)/zshenv $(HOME)/.zshenv
	/bin/ln -fs $(CURDIR)/digrc $(HOME)/.digrc
	rm -f $(HOME)/.config/fish && /bin/ln -fs $(CURDIR)/fish $(HOME)/.config/fish
	/bin/ln -fs $(CURDIR)/gitconfig $(HOME)/.gitconfig
	rm -f $(HOME)/.vim && /bin/ln -fs $(CURDIR)/vim $(HOME)/.vim
	/bin/ln -fs $(CURDIR)/vim/vimrc $(HOME)/.vimrc
	mkdir -p $(HOME)/.config/gitui
	/bin/ln -fs $(CURDIR)/gitui/theme.ron $(HOME)/.config/gitui/theme.ron
	/bin/ln -fs $(CURDIR)/gitui/key_bindings.ron $(HOME)/.config/gitui/key_bindings.ron
	mkdir -p $(HOME)/.gnupg && chmod 700 $(HOME)/.gnupg
	/bin/ln -fs $(CURDIR)/gnupg/gpg.conf $(HOME)/.gnupg/gpg.conf
	rm -rf $(HOME)/.config/bat && /bin/ln -fs $(CURDIR)/bat $(HOME)/.config/bat
	bat cache --build >/dev/null

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

claude_skill_names := github-commit-staged github-issue-create github-pr-create github-pr-merge code-development code-review code-simplification
claude_skills_dir := $(claude_dir)/skills

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
	mkdir -p $(claude_dir) $(claude_skills_dir)
	/bin/ln -fs $(CURDIR)/claude/settings.json $(claude_dir)/settings.json
	$(foreach s,$(claude_skill_names),rm -rf $(claude_skills_dir)/$(s) && /bin/ln -fs $(CURDIR)/claude/skills/$(s) $(claude_skills_dir)/$(s);)

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

ssh-save: ## Re-encrypt ~/.ssh/config to repo
	$(call header,SSH - Encrypt config)
	gpg -er E4AFCA7FBB19FC029D519A524AEBB5178D5E96C1 -o $(CURDIR)/ssh/config.gpg $(ssh_dir)/config

###############################################################################
# Prompt
###############################################################################

prompt:
	echo -n "$(blue)Continue? (yes/no)$(reset)"
	read -p ": " answer && [ "$$answer" = "yes" ] || exit 1
