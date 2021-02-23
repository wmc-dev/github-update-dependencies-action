#!/bin/bash
set -e
token=$1
customScript=$2

if [ ! $token ]; then
 echo "Token missing"
fi

npm set @wmc-dev:registry https://npm.pkg.github.com/
npm set '//npm.pkg.github.com/:_authToken' "$token"

echo "Install dependencies..."
npm ci

# NPM PACKAGES
echo "Update npm packages..."
echo "Get outdated packages..."
if npm outdated | grep "^@wmc-dev/"; then
  wmcOutdated=$(npm outdated | grep "^@wmc-dev/" | awk '{ print $1 "@latest"}')
  echo "Packages found for update"
  echo "$wmcOutdated"
  echo "Install new packages..."
  npm i $wmcOutdated
  git add package.json package-lock.json
  PACKAGE_UPDATED="true"
  echo "New packages installed"
else 
  echo "NPM packages are up to date"
fi

# SUBMODULES
echo "Update submodules..."
if [ -f ./.gitmodules ]; then
  for i in $(grep path ./.gitmodules | sed 's/.*= //'); do
    git submodule update --quiet --init $i
    HASH_BEFORE=$(git submodule status $i)
    git submodule update --quiet --init --remote ./$i
    HASH_AFTER=$(git submodule status $i)
    echo "BEFORE: $HASH_BEFORE"
    echo "AFTER: $HASH_AFTER"
    if [[ "$HASH_BEFORE" == "$HASH_AFTER" ]]; then
      echo "nothing changed in $i!"
    else
      git add $i
      MODULE_UPDATED="true"
    fi
  done
else
  echo "Submodules are up to date"
fi

if [ ! $customScript ]; then
  bash $customScript
fi

# CHECK IN CHANGES
if [[ $PACKAGE_UPDATED = "true" || $MODULE_UPDATED = "true" ]]; then 
  git config --local user.email "action@github.com"
  git config --local user.name "Autoupdate Bot"
  git commit -m"Auto update dependencies"
  git push
else
  echo "Nothing to update"
fi
