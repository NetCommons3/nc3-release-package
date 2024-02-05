#!/bin/bash

####################################
# 環境変数（必要に応じで変更する）
####################################

PROFILEDIR=$(cd $(dirname $(dirname $0)); pwd)
source ${PROFILEDIR}/nc3profile


#######################################
# 前verのアップグレード処理
#######################################

echo ""
echo "+----------------------------------------+"
echo " 前verのアップグレード処理(($OLDVERSION->$NC3VERSION)"
echo "+----------------------------------------+"

if [ ! -d $CHKDIR-upd ]; then
	echo "$CHKDIR-updが存在しません。"
	exit 1
fi

execute "cp -Rpf $PKGDIR/$PROJECTNAME/. $CHKDIR-upd/" "force"

#-- end --
