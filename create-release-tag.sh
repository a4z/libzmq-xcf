

submodules_did_change() {
    git submodule update --remote
    SUBMODULE_CHANGES=$(git status --short --untracked-files=no)

    if [ -n "$SUBMODULE_CHANGES" ]; then
        echo "Update in submodules:"
        echo "$SUBMODULE_CHANGES"
        return 0
    else
        echo "No changes in the submodules."
        return 1
    fi
}

if submodules_did_change; then
    echo "Submodules have changes."
    git add -u .
    git commit -m "Update submodules to the latest commit"
    git push origin main
else
    echo "No new tag required."
    exit 0
fi

REPO_URL="git@github.com:a4z/libzmq-xcf.git"
git fetch --tags
LATEST_TAG=$(git tag --sort=-v:refname | grep -E "^v4\.3\.5\-\d{6}_\d+$" | head -n 1)
TODAY=$(date +%y%m%d)

if [[ ${LATEST_TAG} =~ ^v4\.3\.5\-([0-9]{6})_([0-9]+)$ ]]; then
    LATEST_DATE="${BASH_REMATCH[1]}"
    LATEST_BUILD_NR="${BASH_REMATCH[2]}"
    if [[ $LATEST_DATE == ${TODAY} ]]; then
        BUILD_NR=$((LATEST_BUILD_NR + 1))
    else
        BUILD_NR=1
    fi
else
    BUILD_NR=1
fi

NEW_TAG="v4.3.5-${TODAY}_${BUILD_NR}"
echo "Create new tag: ${NEW_TAG}"
git tag -a ${NEW_TAG} -m "Release ${NEW_TAG}"

echo "TODO: Push the new tag to the remote repository. Run:"
echo  git push origin ${NEW_TAG}
