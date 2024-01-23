#!/bin/bash

####################################
# 環境変数（必要に応じで変更する）
####################################

PROFILEDIR=$(cd $(dirname $0); pwd)
source ${PROFILEDIR}/nc3profile

if [ ! "${MODE}" = "" ]; then
	#MODE=prod; export MODE
	MODE=test; export MODE
fi

################################
# NetCommons3パッケージの作成
################################

# composer.lockファイルを作り直す
execute "bash -l $CURDIR/shells/createComposerLock.sh" "force"
execute "cd $CURDIR"

# waiting 100秒
waiting 10 10


# NetCommons3パッケージの作成
execute "bash -l $CURDIR/shells/createNC3Package.sh" "force"
execute "cd $CURDIR"

# waiting 100秒
waiting 10 10

# 動作確認サイトの構築
execute "bash -l $CURDIR/shells/createCheckNC3.sh" "force"
#execute "bash -l $CURDIR/shells/updateCheckNC3.sh" "force"
execute "cd $CURDIR"

echo "##################################"
echo "# End Shell(`date '+%y-%m-%d %H:%M:%S'`)   #"
echo "##################################"
echo ""
#-- end --
