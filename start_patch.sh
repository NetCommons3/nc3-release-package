#!/bin/bash

####################################
# 引数にdevを付けるとdevブランチも含めて取得する
# 使い方)
# bash start_patch.sh
####################################


####################################
# 環境変数（必要に応じで変更する）
####################################

PROFILEDIR=$(cd $(dirname $0); pwd)
source ${PROFILEDIR}/nc3profile

if [ ! "${MODE}" = "" ]; then
	#MODE=prod; export MODE
	MODE=test; export MODE
fi

#######################################
# 既にあるディレクトリ・ファイルの削除
#######################################

echo ""
echo "##################################"
echo "# Start Shell(`date '+%y-%m-%d %H:%M:%S'`) #"
echo "##################################"
echo ""

PKGNAME=nc${PATCHVERSION//./-}; export PKGNAME
PKGDIR=${CURDIR}/package/$PKGNAME; export PKGDIR
NC3WORKNAME=$PROJECTNAME-work
NC3WORKDIR=$PKGDIR/$NC3WORKNAME

MODE="stable"
IGNORE_PLUGINS=""

if [ ! "$2" = "" ]; then
  MODE="$1"
  IGNORE_PLUGINS="$2"
elif [ "$1" = "dev" -o "$1" = "stable" ]; then
  MODE="$1"
  IGNORE_PLUGINS=""
elif [ ! "$1" = "" ]; then
  MODE="stable"
  IGNORE_PLUGINS="$1"
fi

execute "cd $CURDIR"

if [ ! -d $WORKDIR ]; then
	execute "mkdir $WORKDIR"
fi

if [ ! -d $PKGDIR ]; then
	execute "mkdir $PKGDIR"
fi

if [ -d $PKGDIR/$PROJECTNAME ]; then
	execute "rm -Rf $PKGDIR/$PROJECTNAME"
fi

#################################
## githubから最新のソースを取得
#################################

if [ ! -d $NC3WORKDIR ]; then
	execute "git clone $GITAUTHURL/$PROJECTNAME"
  execute "mv $PROJECTNAME $NC3WORKDIR"
fi

execute "cd $NC3WORKDIR"
if [ ! -f composer.lock.dist ]; then
  execute "mv composer.lock composer.lock.dist"
fi

if [ $MODE = "dev" ]; then
  execute "composer config minimum-stability dev"
fi

execute "composer update --no-dev" "no-exec"
COMPOSER_MEMORY_LIMIT=-1 composer update --no-dev

################################
# 変更点チェック
################################

cd $CURDIR
RELEASE_PLUGINS=`php $CURDIR/shells/releaseVersionDiff.php $NC3WORKDIR/composer.lock.dist $NC3WORKDIR/composer.lock plugin $IGNORE_PLUGINS`
RELEASE_PACKAGES=`php $CURDIR/shells/releaseVersionDiff.php $NC3WORKDIR/composer.lock.dist $NC3WORKDIR/composer.lock space $IGNORE_PLUGINS`
if [ "${HOGE:0:7}" = "[Error]" ]; then
  echo $RELEASE_PACKAGES
  exit 1
fi

#echo $RELEASE_PLUGINS
#echo $RELEASE_PACKAGES

execute "cd $PKGDIR"
execute "mkdir -p $PROJECTNAME/app/Plugin"
for plugin in $RELEASE_PLUGINS
do
  execute "cp -Rpf $NC3WORKNAME/app/Plugin/$plugin $PROJECTNAME/app/Plugin/"
done

#############################################
# 差分プラグインのみcomposer.lockファイルに反映する
#############################################

if [ ! "$RELEASE_PACKAGES" = "" ]; then
  execute "cd $NC3WORKDIR"
  execute "cp -pf composer.lock.dist composer.lock"
  execute "composer install --no-dev"
  execute "composer require $RELEASE_PACKAGES"

  execute "git checkout composer.json"

  execute "cd $PKGDIR"
  execute "cp -Rpf $NC3WORKNAME/composer.lock $PROJECTNAME/"

  if [ -f NetCommons-$PATCHVERSION.zip ]; then
    execute "rm NetCommons-$PATCHVERSION.zip"
  fi
  execute "zip -r NetCommons-$PATCHVERSION.zip $PROJECTNAME"
fi

echo "##################################"
echo "# End Shell(`date '+%y-%m-%d %H:%M:%S'`)   #"
echo "##################################"
echo ""
#-- end --
