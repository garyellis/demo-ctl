
# gets the latest commit in a merge commit
function get_merged_commit(){
   if [ ! -z "$GIT_SHORT_COMMIT" ]; then
     currentcommit="$GIT_SHORT_COMMIT"
   else
     currentcommit=$(git rev-parse --short HEAD)
   fi
   mergecommitlog="$(git log --oneline --merges --no-color -n1)"
   mergecommit=$(awk '{print $1}' <<<$mergecommitlog)
   if [ "$currentcommit" != "$mergecommit" ]; then
     echo "current commit is not a merge commit; current: $currentcommit, mergecommit: $mergecommit"
     return 1;
   else
     mergecommit_pull_number=$(sed -n 's/.*Merge pull request \#\([0-9]\+\).*/\1/p' <<<$mergecommitlog)
     merged_commit=$(gh pr view $mergecommit_pull_number --json commits|jq '.commits[-1]|.oid ' -r)
     merged_short_commit="$(git rev-parse --short $merged_commit)"
   fi
   
   echo $merged_short_commit
}

function release_from_merged_commit(){

    set -x
    merged_commit="$(get_merged_commit)"
    echo $merged_commit
    docker pull $IMAGE_NAME:$merged_commit
    docker tag $IMAGE_NAME:$merged_commit $IMAGE_NAME:$VERSION
    docker push $IMAGE_NAME:$VERSION
    set +x
}

eval "$@"
