# NPM PACKAGES
echo "Update npm packages..."
if npm outdated | grep @wmc-dev/; then
  packages=$(grep -o '@wmc-dev/[^"]*' ./package.json | awk '{ print $1 "@latest"}')
  npm i $packages
  git add package.json package-lock.json
  PACKAGE_UPDATED="true"
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
fi

# CHECK IN CHANGES
if [[ $PACKAGE_UPDATED = "true" || $MODULE_UPDATED = "true" ]]; then 
  git config --local user.email "action@github.com"
  git config --local user.name "Autoupdate Bot"
  git commit -m"Auto update dependencies"
  git push
fi