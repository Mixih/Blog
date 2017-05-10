#!/bin/bash
set -e

echo -e "Deploying to github pages now...\n"
TIME=$(date +%Y-%m-%dT%H:%M:%S%:z)
DEPLOY_BRANCH="master"
SRC_REPO="mixih/Blog"


cd $TRAVIS_BUILD_DIR
SHA=$(git rev-parse HEAD)
echo "Revision sha: $SHA\n"
openssl aes-256-cbc -K $encrypted_f72775598588_key -iv $encrypted_f72775598588_iv -in  $TRAVIS_BUILD_DIR/.ci/deploy_key.enc -out $TRAVIS_BUILD_DIR/deploy_key -d
chmod 600 $TRAVIS_BUILD_DIR/deploy_key
eval $(ssh-agent -s)
ssh-add deploy_key

echo -e "\nChecking out deployment repo...\n"
git clone git@github.com:Mixih/mixih.github.io.git deploy_web
cd $TRAVIS_BUILD_DIR/deploy_web
git config user.name $GH_NAME
git config user.email "$GH_EMAIL"
git checkout $DEPLOY_BRANCH
rm -rf ./*
cp -rf $TRAVIS_BUILD_DIR/public/* .

if git diff --quiet; then
    echo "No changes, exiting..."
    exit 0
fi

echo -e "\nPushing to deployment repo...\n"
git add -A
git commit -m "$(printf "Website update $TIME\n\nDeployed by travis for commit\nmixih/Blog@$SHA")"
git push origin $DEPLOY_BRANCH

echo "Deployed successfully, revision $SHA!"
