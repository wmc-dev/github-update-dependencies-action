# github-update-dependencies-action
## How to use
````
- name: Update dependencies
  uses: wmc-dev/github-update-dependencies-action@master
  with:
    token: ${{ secrets.TOKEN }}
    customScript: updateDependencies.sh
````

The custom script will be executed after all dependencies were updated and right before checking in the changes regardless of wether there where any dependencies updates or not