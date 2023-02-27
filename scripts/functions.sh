
# gets the latest commit in a merge commit
function get_merged_commit(){
   currentcommit=$(git rev-parse --short HEAD)
   mergecommitlog="$(git log --oneline --merges --no-color -n1)"
   mergecommit=$(awk '{print $1}' <<<$mergecommitlog)
   if [ "$currentcommit" != "$mergecommit" ]; then
     echo "current commit is not a merge commit; current: $currentcommit, mergecommit: $mergecommit"
     return 1;
   else
     mergecommit_pull_number=$(sed -n 's/.*Merge pull request \#\([0-9]\+\).*/\1/p' <<<$mergecommitlog)
     merged_commit=$(gh pr view $mergecommit_pull_number --json commits|jq '.commits[-1]|.oid ' -r)
   fi
   
   echo $merged_commit
}
