#!/bin/bash
#---------------------------------------------------------
# written by: lawrence mcdaniel
#             https://lawrencemcdaniel.com
#             https://blog.lawrencemcdaniel.com
#
# date:       feb-2018
#
# usage:      Compile Open edX static assets. See http://edx.readthedocs.io/projects/edx-developer-guide/en/latest/pavelib.html
#             Compiles Coffeescript, Sass, and Xmodule assets, and runs Django's collectstatic.
#
#             This process is required any time you change your custom theme, or if you Add
#             new static assets (like images, pdf documents, custom CSS / JS) to an existing theme.
#
#             Compiling (and "transpiling") assets is the process of translating CSS templates and source files
#             like SASS and Coffee scripts into final CSS files, plus, moving these files from their
#             locations in the code base folder structure to the Nginx locations for hosting purposes.
#             files also pickup codified suffixes as part of this process.
#
# NOTE:       This script initiates the asset compilation process, which takes around 10 minutes to complete.
#             Your Open edX platform will be unavailable during the compilation process.
#
# reference:  https://openedx.atlassian.net/wiki/spaces/OpenOPS/pages/60227913/Managing+OpenEdX+Tips+and+Tricks
#---------------------------------------------------------

cd ~
COMPILER_LOCK=".compile_assets"

#Check to see if a compilation process is currently running. if so then exit
if [ -f "$COMPILER_LOCK" ]; then
  prev_launch=$(stat -c %y .compile_assets)
  echo "Cannot start: a Compile Assets process was launched at ${prev_launch:1:16}. Exiting"
  echo
  echo "If you know this to be incorrect information then you can do a hard reset with the following command: sudo rm ${COMPILER_LOCK}" 
  exit
else
  touch $COMPILER_LOCK
  echo "Asset compilation is now locked."
fi

# ensure permissions are good across all of edx-platform 
sudo chown -R edxapp /edx/app/edxapp/edx-platform
sudo chgrp -R edxapp /edx/app/edxapp/edx-platform

# update assets as edxapp user
sudo -H -u edxapp bash << EOF
source /edx/app/edxapp/edxapp_env
cd /edx/app/edxapp/edx-platform
echo "
  --------------------------------------------------------------
  ____                      _ _                _     __  __ ____
 / ___|___  _ __ ___  _ __ (_) | ___          | |   |  \/  / ___|
| |   / _ \| '_   _ \| '_ \| | |/ _ \  _____  | |   | |\/| \___ \
| |__| (_) | | | | | | |_) | | |  __/ |_____| | |___| |  | |___) |
 \____\___/|_| |_| |_| .__/|_|_|\___|         |_____|_|  |_|____/
                     |_|
  --------------------------------------------------------------
"
paver --quiet update_assets lms --settings=aws --theme-dirs /edx/app/edxapp/edx-platform/themes --themes=tailoredlabs
echo "
  --------------------------------------------------------------
  ____                      _ _                ____  _
 / ___|___  _ __ ___  _ __ (_) | ___          / ___|| |_ _   _  __| (_) ___
| |   / _ \| '_   _ \| '_ \| | |/ _ \  _____  \___ \| __| | | |/    | |/ _ \
| |__| (_) | | | | | | |_) | | |  __/ |_____|  ___) | |_| |_| | (_| | | (_) |
 \____\___/|_| |_| |_| .__/|_|_|\___|         |____/ \__|\__,_|\__,_|_|\___/
                     |_|
  --------------------------------------------------------------
"
paver --quiet update_assets cms --settings=aws --theme-dirs /edx/app/edxapp/edx-platform/themes --themes=tailoredlabs
echo "
  --------------------------------------------------------------
  ____                      _ _                _     __  __ ____
 / ___|___  _ __ ___  _ __ (_) | ___          | |   |  \/  / ___|
| |   / _ \| '_   _ \| '_ \| | |/ _ \  _____  | |   | |\/| \___ \
| |__| (_) | | | | | | |_) | | |  __/ |_____| | |___| |  | |___) |
 \____\___/|_| |_| |_| .__/|_|_|\___|         |_____|_|  |_|____/
                     |_|
  Making it Sassy with Sass :D
  --------------------------------------------------------------
"
paver compile_sass --system=lms --theme-dirs /edx/app/edxapp/edx-platform/themes --themes=tailoredlabs
echo "
  --------------------------------------------------------------
  ____                      _ _                ____  _
 / ___|___  _ __ ___  _ __ (_) | ___          / ___|| |_ _   _  __| (_) ___
| |   / _ \| '_   _ \| '_ \| | |/ _ \  _____  \___ \| __| | | |/    | |/ _ \
| |__| (_) | | | | | | |_) | | |  __/ |_____|  ___) | |_| |_| | (_| | | (_) |
 \____\___/|_| |_| |_| .__/|_|_|\___|         |____/ \__|\__,_|\__,_|_|\___/
                     |_|
  Making it Sassy with Sass :D
  --------------------------------------------------------------
"
paver compile_sass --system=cms --theme-dirs /edx/app/edxapp/edx-platform/themes --themes=tailoredlabs
EOF

# restart edx instances
/edx/bin/supervisorctl restart lms
/edx/bin/supervisorctl restart cms
/edx/bin/supervisorctl restart edxapp_worker:

now=$(date -d "-6 hours" +'%H:%M')
echo "$now CST: finished compiling assets"
rm $COMPILER_LOCK
echo "Asset compilation is now unlocked."

