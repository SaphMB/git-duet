#!/usr/bin/env bats

load test_helper

@test "writes the pre-commit hook to the pre-commit hook file" {
  run git duet-install-hook -q pre-commit
  assert_success
  [ -f .git/hooks/pre-commit ]
}

@test "writes the prepare-commit-msg hook to the prepare-commit-msg hook file" {
  run git duet-install-hook -q prepare-commit-msg
  assert_success
  [ -f .git/hooks/prepare-commit-msg ]
}

@test "makes the pre-commit hook executable" {
  run git duet-install-hook -q pre-commit
  assert_success
  [ -x .git/hooks/pre-commit ]
}

@test "does not overwrite existing hook file with other contents" {
  echo "Some content" > .git/hooks/prepare-commit-msg
  run git duet-install-hook -q prepare-commit-msg
  assert_failure
}

@test "overwrites existing hook file with empty contents" {
  touch .git/hooks/prepare-commit-msg
  run git duet-install-hook -q prepare-commit-msg
  assert_success
}

@test "does not write anything if hook file with desired content already exists" {
  echo '#!/usr/bin/env bash
exec git duet-prepare-commit-msg "$@"' > .git/hooks/prepare-commit-msg
  run git duet-install-hook -q prepare-commit-msg
  assert_success
}

@test "requires hook file as argument" {
  run git duet-install-hook -q notAHookFile
  assert_failure
  assert_line "Usage: git-duet-install-hook [-hq] { pre-commit | prepare-commit-msg }"
}

@test "writes global prepare-commit-msg hook file if GIT_DUET_GLOBAL is set" {
  GIT_DUET_GLOBAL=1 git duet-install-hook -q prepare-commit-msg
  assert_success
  [ -f $HOME/.git-template/hooks/prepare-commit-msg ]
}

@test "writes global pre-commit hook file if GIT_DUET_GLOBAL is set" {
  GIT_DUET_GLOBAL=1 git duet-install-hook -q pre-commit
  assert_success
  [ -f $HOME/.git-template/hooks/pre-commit ]
}

@test "writes global prepare-commit-msg hook file if GIT_DUET_GLOBAL is set respecting current init.templatedir" {
  git config --global init.templatedir .
  GIT_DUET_GLOBAL=1 git duet-install-hook -q prepare-commit-msg
  assert_success
  [ -f ./hooks/prepare-commit-msg ]
}
