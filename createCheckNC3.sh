#!/bin/bash

####################################
# 環境変数（必要に応じで変更する）
####################################

. ./nc3profile

#######################################
# 動作確認サイトの構築
#######################################

echo ""
echo "+----------------------------------------+"
echo " 動作確認サイトの構築($NC3VERSION)"
echo "+----------------------------------------+"

if [ ! -d $PKGDIR/$PROJECTNAME ]; then
	echo "$PKGDIR/$PROJECTNAMが存在しません。"
	exit 1
fi
if [ -d $CHKDIR ]; then
	execute "rm -Rf $CHKDIR"
fi

execute "cp -Rpf $PKGDIR/$PROJECTNAME $CHKDIR"

execute "mysql -u${DBUSER} -p${DBPASS} -e \"drop database if exists ${DBNAME};\"" "no-exec"
mysql -u${DBUSER} -p${DBPASS} -e "drop database if exists ${DBNAME};"


#-- end --
