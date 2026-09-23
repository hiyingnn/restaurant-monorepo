#!/bin/bash
#
# merge-ms.sh (trunk-based)
#
# Consolidates the three "order-service / customer-service / food-service" polyrepos
# into a single Maven multi-module monorepo ("restaurant-monorepo"), preserving full
# Git history (via git-filter-repo) on a single `main` branch per repo.
#
# This is the PoC version of the script referenced in the article's Phase B
# ("Migration to Monorepo using Git, preserve Git history via git-filter-repo").
# All four *_URL variables below already default to real GitHub remotes - override
# any of them (env var) to point at a fork or a different account instead.
#
# Trunk-based note: each polyrepo here has ONE branch (main). There is no
# dev/staging/demo propagation step - environment-specific config lives as Spring
# profiles committed straight to main (see application-staging.yml / application-demo.yml
# in each service), which is what makes a single-branch merge possible in the first place.
#
# Prerequisites:
#   1. git-filter-repo installed (see restaurant-monorepo/README.md "Setup" section,
#      or: pip install git-filter-repo --break-system-packages)
#   2. An empty "restaurant-monorepo" repo already created on GitHub (no README/
#      license/.gitignore) - this script pushes into it, it does not create it.
#   3. Your local git already authenticated to GitHub (SSH key or credential
#      manager) - same requirement as any other `git push` to your account.

set -e

# Captured once, before any `cd`, so a local-path override (if you use one) resolves
# correctly no matter which directory each git command later runs from. Unused with
# the real https://github.com/... defaults below.
WORKSPACE_DIR="$(pwd)"

# --- Configuration ---
# The three source polyrepos are real, public GitHub repos - no auth needed to read them.
# MONOREPO_URL now defaults to the real restaurant-monorepo on GitHub. Create that repo
# empty first (no README/license/gitignore) - this script pushes into it, it doesn't
# create it on GitHub's side. Pushing requires your local machine's own GitHub auth
# (SSH key or credential manager) to already be set up, same as any other git push.
MONOREPO_ROOT="restaurant-monorepo"
MONOREPO_URL="${MONOREPO_URL:-https://github.com/hiyingnn/restaurant-monorepo.git}"

ORDER_SERVICE_URL="${ORDER_SERVICE_URL:-https://github.com/hiyingnn/order-service.git}"
CUSTOMER_SERVICE_URL="${CUSTOMER_SERVICE_URL:-https://github.com/hiyingnn/customer-service.git}"
FOOD_SERVICE_URL="${FOOD_SERVICE_URL:-https://github.com/hiyingnn/food-service.git}"

# --- Function to Merge a Single Microservice (main branch only) ---
merge_microservice() {

    local MS_NAME="$1"
    local MS_URL="$2"
    local TEMP_DIR="${MS_NAME}-temp"
    local SUBDIRECTORY="services/${MS_NAME}"

    # Define absolute paths based on the script's entry point (the parent directory)
    local PARENT_PATH="$(pwd)"
    local MONOREPO_PATH="${PARENT_PATH}/${MONOREPO_ROOT}"

    echo "==========================================================="
    echo "Starting merge for: ${MS_NAME}"
    echo "-----------------------------------------------------------"

    # --- 1. Filter History (Must run from PARENT_PATH) ---
    echo "1. Cloning and filtering history..."
    cd "${PARENT_PATH}" # Ensure we are in the parent directory

    git clone --mirror "${MS_URL}" "${TEMP_DIR}"

    cd "${TEMP_DIR}" || { echo "ERROR: Cannot enter temporary directory ${TEMP_DIR}"; exit 1; }
    # --force: filter-repo refuses to run if TEMP_DIR doesn't look like a brand-new,
    # never-touched clone (e.g. if a previous failed run left artifacts behind, or the
    # source was a local path rather than a real remote). --force bypasses that
    # heuristic safety check only - it does not change what the rewrite itself does.
    # Safe here because TEMP_DIR is always a disposable --mirror clone deleted at the
    # end of this function.
    git filter-repo --to-subdirectory-filter "${SUBDIRECTORY}" --force
    cd "${PARENT_PATH}" # Return to parent directory

    # --- 2. Setup Remote and Fetch (Must run from MONOREPO_PATH) ---
    echo "2. Fetching filtered history..."

    cd "${MONOREPO_PATH}" || { echo "ERROR: Failed to enter monorepo directory ${MONOREPO_PATH}"; exit 1; }

    git remote add "${TEMP_DIR}" "${PARENT_PATH}/${TEMP_DIR}"
    git fetch "${TEMP_DIR}"

    # --- 3. Merge into the monorepo's single `main` branch ---
    # Every service's history is unrelated to the monorepo's own initial commit
    # (and to the other services already merged in), so --allow-unrelated-histories
    # is required for each one, not just the first.
    echo "   -> Merging ${MS_NAME}/main..."
    git checkout main
    git merge "${TEMP_DIR}/main" --allow-unrelated-histories -m "Merge ${MS_NAME} history into monorepo"
    git push -u origin main

    # --- 4. Clean Up (Run from MONOREPO_PATH) ---
    echo "4. Cleaning up temporary remote and directory..."
    git remote remove "${TEMP_DIR}"

    cd "${PARENT_PATH}"
    rm -rf "${TEMP_DIR}"

    echo "-----------------------------------------------------------"
    echo "${MS_NAME} merge complete."
    echo "==========================================================="
}

# -----------------------------------------------------------------------
# EXECUTION
# -----------------------------------------------------------------------

PARENT_DIR_FOR_SCRIPT="$(pwd)"
cd "${PARENT_DIR_FOR_SCRIPT}" || exit

# --- 1. Initialize Monorepo (Run once outside the function) ---
if [ ! -d "${MONOREPO_ROOT}" ]; then
    echo "--- INITIALIZING NEW MONOREPO ---"

    mkdir "${MONOREPO_ROOT}"
    cd "${MONOREPO_ROOT}"
    git init -b main
    # Ensure the monorepo's own commits (init + merge commits) carry the same
    # identity as the service commits, regardless of this machine's global git config.
    git config user.name "${GIT_AUTHOR_NAME:-Ren Ying}"
    git config user.email "${GIT_AUTHOR_EMAIL:-REN_YING@csit.gov.sg}"
    git commit --allow-empty -m "chore: initialize restaurant-monorepo"

    git remote add origin "${MONOREPO_URL}"
    git push -u origin main

    cd .. # Return to PARENT_DIR_FOR_SCRIPT
fi

# --- 2. Execute Merges ---
# IMPORTANT: Ensure you start with a clean monorepo (delete previous failed runs).
merge_microservice "order-service" "${ORDER_SERVICE_URL}"
merge_microservice "customer-service" "${CUSTOMER_SERVICE_URL}"
merge_microservice "food-service" "${FOOD_SERVICE_URL}"

echo "--- ALL MERGES COMPLETE ---"

# --- 3. Carry documentation into the monorepo (optional) ---
# If README.md and/or a docs/ folder sit next to this script, add them to the
# monorepo and push, so the finished repo is self-documenting on GitHub too.
cd "${PARENT_DIR_FOR_SCRIPT}"
if [ -f "README.md" ] || [ -d "docs" ]; then
    echo "--- Adding documentation to monorepo ---"
    cd "${MONOREPO_ROOT}"
    [ -f "../README.md" ] && cp "../README.md" .
    [ -d "../docs" ] && cp -r "../docs" .
    cp "../merge-ms.sh" . 2>/dev/null || true
    git add -A
    git commit -q -m "docs: add migration README, merge-ms.sh and execution screenshots" || echo "(nothing new to commit)"
    git push origin main
    cd "${PARENT_DIR_FOR_SCRIPT}"
fi
