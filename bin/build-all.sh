#! /bin/bash -x

export DISPLAY=:0;

date=$(date +"%F");

mkdir $date;
mkdir $date/apk-arm;
mkdir $date/apk-shared;
mkdir $date/apk-x86;
mkdir $date/crx;
mkdir $date/sdk;
mkdir $date/wgt;
mkdir $date/xpk;

#xwalk_android_dl -a arm;
#xwalk_android_dl -a x86;
xwalkversion=$(awk -F- '{print $2}'<<<$(ls -1d crosswalk*/ | tail -n1));

for app in webapps-*/;
do
  echo --------------------------------------------- $app ----------------------------------------;
  cd $app;

  name=$(awk -F: '/"name"/ { print $2 }' package.json | tr -d ', "');
  version=$(awk -F: '/"version"/ { print $2 }' package.json | tr -d ', "');
  nameandversion=${name}-${version};

  echo cleaning up;
  git clean -dfx;
  npm install;
  bower install;

  #apk-arm
  echo building xpk;
  grunt xpk;
  echo building crosswalk:arm;
  XWALK_APP_TEMPLATE=$(echo ../crosswalk*arm/xwalk_app_template) grunt crosswalk:arm;
  echo copying;
  cp $(ls -1 build/*.apk | grep -v signed) ../$date/apk-arm/${name}-${version}-${xwalkversion}.arm.apk;

  #apk-shared
  echo building xpk;
  grunt xpk;
  echo building crosswalk:shared;
  XWALK_APP_TEMPLATE=$(echo ../crosswalk*x86/xwalk_app_template) grunt crosswalk:shared;
  echo copying;
  cp $(ls -1 build/*.apk | grep -v signed) ../$date/apk-shared/${name}-${version}-${xwalkversion}.apk;

  #apk-x86
  echo building xpk;
  grunt xpk;
  echo building crosswalk:shared;
  XWALK_APP_TEMPLATE=$(echo ../crosswalk*x86/xwalk_app_template) grunt crosswalk:x86;
  echo copying;
  cp $(ls -1 build/*.apk | grep -v signed) ../$date/apk-x86/${name}-${version}-${xwalkversion}.x86.apk;

  #crx
  # .zip
  echo building crx-zip;
  grunt crx_unpacked;
  echo copying;
  cp build/*.zip ../$date/crx;
  # make .crx from .zip
  mkdir ${nameandversion};
  unzip build/*.zip -d ${nameandversion};
  cp platforms/chrome-crx/*.pem .;
  google-chrome --pack-extension=${nameandversion} --pack-extension-key=${name}.pem;
  cp ${nameandversion}.crx ../$date/crx/;

  #sdk
  echo building sdk;
  grunt sdk;
  echo copying;
  cp build/*.zip ../$date/sdk;

  #wgt
  echo building wgt;
  grunt wgt;
  echo copying;
  cp build/*.wgt ../$date/wgt;

  #xpk
  echo building xpk;
  grunt xpk;
  echo packaging;
  make_xpk.py build/xpk -o ../$date/xpk/${nameandversion}.xpk platforms/tizen-xpk/signature;

  cd -;
done;