#!/usr/bin/env bash


function get_merged_commit(){
# gets the latest commit in a merge commit
# depends on env variables: 

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


function release_image(){
# pulls the image from the most recently merged pull request, tags and pushes it to the registry
# depends on env variables: IMAGE_NAME, VERSION

    merged_commit="$(get_merged_commit)"
    echo $merged_commit
    docker pull $IMAGE_NAME:$merged_commit
    docker tag $IMAGE_NAME:$merged_commit $IMAGE_NAME:$VERSION
    docker push $IMAGE_NAME:$VERSION
}

function release_gh(){
# creates a github release and generate notes after latest release
# $1=tag to create
# depends on env variables:

    
    gh_release_list="$(gh release list
      --exclude-drafts \
      --exclude-pre-releases \
      --limit 100000 2>/dev/null)"
    notes_start_tag="$(awk '$2 ~ /Latest/ {printf "--notes-start-tag %s", $1}' <<<$gh_release_list)"


    gh release create $1 \
      --title "Release $1" \
      --latest \
      --generate-notes \
      $notes_start_tag
}

eval "$@"
