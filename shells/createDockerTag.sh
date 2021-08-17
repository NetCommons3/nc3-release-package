#!/bin/bash

####################################
# 環境変数（必要に応じで変更する）
####################################

PROFILEDIR=$(cd $(dirname $(dirname $0)); pwd)
source ${PROFILEDIR}/nc3profile


#######################################
# nc3app-dockerタグ付けの変更
# -> Dockerイメージの作成
#######################################

revision=$1
if [ "${revision}" = "" ]; then
	echo "リビジョンを指定してください。"
	exit 1
fi

echo ""
echo "+----------------------------------------+"
echo " リリースタグ付け(nc3app-docker:$DOCKERVERSION.${revision})"
echo "+----------------------------------------+"

if [ ! -d $DOCKERDIR ]; then
	execute "cd $WORKDIR"
	execute "git clone $GITAUTHURL/nc3app-docker.git $DOCKERDIR"
fi
execute "cd $DOCKERDIR"
execute "git pull"

execute "git tag v${DOCKERVERSION}.${revision}"
execute "git push origin v${DOCKERVERSION}.${revision}"

#-- end --
