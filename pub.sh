#!/bin/bash
set -e

cd ~/Dropbox/01-rsch/2026-OHS-HST/hstblog
[ -f ../.venv/bin/activate ] && source ../.venv/bin/activate

# 1단계: 백업 커밋
git add -A
git diff --cached --quiet || git commit -m "backup: before render"
BACKUP_COMMIT=$(git rev-parse HEAD)
echo "Backup commit: $BACKUP_COMMIT"

rollback_on_failure() {
  local exit_code=$?
  echo ""
  echo "pub.sh 실패 (exit $exit_code) — 백업 시점으로 복원"
  git reset --hard "$BACKUP_COMMIT" || true
  git clean -fd || true
  echo "복원 완료. HEAD=$(git rev-parse --short HEAD)"
}
trap rollback_on_failure ERR INT TERM

# 2단계: 렌더
rm -rf docs
quarto render

# 3단계: 커밋
git add -A
git diff --cached --quiet || git commit -m "."
LOCAL_HEAD=$(git rev-parse HEAD)
echo "Local HEAD: $LOCAL_HEAD"

# 4단계: push
git push origin main
echo "Pushed."

trap - ERR INT TERM
