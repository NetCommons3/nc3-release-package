#!/bin/bash

####################################
# 環境変数（必要に応じで変更する）
####################################

PROFILEDIR=$(cd $(dirname $(dirname $0)); pwd)
source ${PROFILEDIR}/nc3profile


#######################################
# composer.lockファイルを作り直す
#######################################

echo ""
echo "+----------------------------------------+"
echo " composer.lockファイルを作り直し($NC3VERSION)"
echo "+----------------------------------------+"

if [ -d $WORKDIR/$PROJECTNAME ]; then
	execute "rm -Rf $WORKDIR/$PROJECTNAME"
fi
execute "cd $WORKDIR"
execute "git clone $GITAUTHURL/$PROJECTNAME.git"
execute "cd $WORKDIR/$PROJECTNAME"

execute "echo \"$NC3VERSION\" > app/VERSION" "no-exec"
echo "$NC3VERSION" > app/VERSION
echo ""

execute "rm -f composer.lock"
execute "${CMDCMPOSER} clear-cache"
execute "${CMDCMPOSER} install --no-dev"

########################
# Githubにプッシュ     #
########################


if [ "${MODE}" = "prod" ]; then
	execute "git add composer.lock"
	execute "git add app/VERSION"

	execute "git commit -m\"NetCommons $NC3VERSION released.\"" "no-exec"
	git commit -m"NetCommons $NC3VERSION released."
	echo ""

	execute "git push"

	execute "git tag $NC3VERSION"
	execute "git push origin $NC3VERSION"
fi


#-- end --
