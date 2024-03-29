#!/bin/bash

####################################
# 環境変数（必要に応じで変更する）
####################################

PROFILEDIR=$(cd $(dirname $(dirname $0)); pwd)
source ${PROFILEDIR}/nc3profile


#######################################
# バージョンの変更
#######################################

plugin=$1
if [ "${plugin}" = "" ]; then
	echo "プラグインを指定してください。"
	exit 1
fi

echo ""
echo "+----------------------------------------+"
echo " バージョンの変更($plugin:$NC3VERSION)"
echo "+----------------------------------------+"

if [ ! -d $WORKDIR/$plugin ]; then
	execute "cd $WORKDIR"
	execute "git clone $GITAUTHURL/$plugin.git"
fi
execute "cd $WORKDIR/$plugin"

execute "echo \"$NC3VERSION\" > VERSION.txt" "no-exec"
echo "$NC3VERSION" > VERSION.txt
echo ""

execute "git add VERSION.txt"

execute "git commit -m\"change: Version number to $NC3VERSION\"" "no-exec"
ret=`git commit -m"change: Version number to $NC3VERSION"`
echo -e $ret
echo ""

if [ ! "`echo $ret | grep 'nothing to commit'`" ]; then
	execute "git push" "prod"

	if [ "$plugin" = "Questionnaires" -o "$plugin" = "Quizzes" -o "$plugin" = "Registrations" ]; then
		# waiting 960秒
		waiting 48 20
	else
		# waiting 300秒
		waiting 30 10
	fi
fi

#-- end --
