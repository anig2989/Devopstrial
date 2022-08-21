#using config.sh as source file
source ./config.sh
SOURCE_REPO_URL="https://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@github.com/anig2989/Devopstrial.git"
NAME_OF_USER="Anirban Hazra"
EMAIL_OF_USER_FOR_DESTINATION_REPO="anig2989@gmail.com"

#defing local repo directory in variable after cloning.
SOURCE_DIRECTORY=`basename "${SOURCE_REPO_URL}" .git`

echo $CURRENT_BRANCH_NAME

#cloning the repo.
echo git clone ${SOURCE_REPO_URL}
git clone ${SOURCE_REPO_URL}

#Entering into directory where the repo is cloned.
echo cd ${SOURCE_DIRECTORY} 
cd ${SOURCE_DIRECTORY}

echo git fetch origin
git fetch origin

destination_exists=$(git ls-remote --heads origin $DESTINATION_BRANCH_NAME | wc -l)
          
if [ $destination_exists == 0 ]; then
  echo "*************  No $DESTINATION_BRANCH_NAME branch exists  *************"
  exit 1
fi

current_exists=$(git ls-remote --heads origin $CURRENT_BRANCH_NAME | wc -l)
          
if [ $current_exists == 0 ]; then
  echo "*************  No $CURRENT_BRANCH_NAME branch exists  *************"
  exit 1
fi

#Creating Promotional branch from destination branch(like CI, QA or UAT).
echo git checkout $DESTINATION_BRANCH_NAME
git checkout $DESTINATION_BRANCH_NAME

echo git checkout -b Promotional-$DESTINATION_BRANCH_NAME-${GITHUB_RUN_ID}-${GITHUB_RUN_NUMBER} $DESTINATION_BRANCH_NAME
git checkout -b Promotional-$DESTINATION_BRANCH_NAME-${GITHUB_RUN_ID}-${GITHUB_RUN_NUMBER} $DESTINATION_BRANCH_NAME

git checkout Promotional-$DESTINATION_BRANCH_NAME-${GITHUB_RUN_ID}-${GITHUB_RUN_NUMBER}

git config --global user.email "${EMAIL_OF_USER_FOR_DESTINATION_REPO}"
git config --global user.name "${NAME_OF_USER}"

git add .
git commit -m "creating promotional branch"
git push origin Promotional-$DESTINATION_BRANCH_NAME-${GITHUB_RUN_ID}-${GITHUB_RUN_NUMBER}

exec_cmd()
{
  echo "$1"
  $1
  return_code=$?
  if [ $return_code -ne 0 ] ; then
    echo "ERROR - $1 failed with $return_code"
    conflicts_exists=0
    while [ $conflicts_exists -eq 0 ]
    do
      echo "grep -lr '<<<<<<<' force-app/ | xargs -d git checkout --theirs"
      grep -lr '<<<<<<<' force-app/ | xargs -d"\n" git checkout --theirs

      grep -lrI '<<<<<<<' force-app/
      conflicts_exists=$?
    done
    git status
    echo git add .
    git add .
    echo git commit -m "resolving merge conflicts"
    git commit -m "resolving merge conflicts"
    echo "*****Conflict Resolved*****"
  else
    echo "No conflict"
  fi
}
echo git merge origin/$CURRENT_BRANCH_NAME
exec_cmd "git merge origin/$CURRENT_BRANCH_NAME"

#Merging current branch with Promotional branch.
#echo git merge origin/$CURRENT_BRANCH_NAME
#git merge origin/$CURRENT_BRANCH_NAME

#Pushing Promotional branch.
exec_cmd()
{
  echo "$1"
  $1
  return_code=$?
  if [ $return_code -ne 0 ] ; then
      
    echo "ERROR - $1 failed with $return_code"
    echo git checkout $DESTINATION_BRANCH_NAME
    git checkout $DESTINATION_BRANCH_NAME

    git checkout -d Promotional-$DESTINATION_BRANCH_NAME-${GITHUB_RUN_ID}-${GITHUB_RUN_NUMBER}
    git push origin --delete Promotional-$DESTINATION_BRANCH_NAME-${GITHUB_RUN_ID}-${GITHUB_RUN_NUMBER}
    exit 1
  else
    echo "Successfully created Promotional-$DESTINATION_BRANCH_NAME-${GITHUB_RUN_ID}-${GITHUB_RUN_NUMBER} branch"
  fi
}
echo git push origin Promotional-$DESTINATION_BRANCH_NAME-${GITHUB_RUN_ID}-${GITHUB_RUN_NUMBER}
exec_cmd "git push origin Promotional-$DESTINATION_BRANCH_NAME-${GITHUB_RUN_ID}-${GITHUB_RUN_NUMBER}"
