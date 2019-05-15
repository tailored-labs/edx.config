#!/bin/bash


sudo rm -rf /home/ubuntu/edx.config
git clone https://github.com/tailored-labs/edx.config.git

sudo cp /home/ubuntu/edx.config/edx/app/edxapp/*.json /edx/app/edxapp/
sudo chown edxapp /edx/app/edxapp/*.json
sudo chgrp www-data /edx/app/edxapp/*.json

echo install theme
sudo rm -r /edx/app/edxapp/edx-platform/lms/themes/tailoredlabs
sudo cp -R /home/ubuntu/edx.config/themes/tailoredlabs /edx/app/edxapp/edx-platform/themes/


# Copy our modified nginx configurations for lms and cms
# these contain lets encrypt ssl certificate and https redirection
#cp /root/edx-config.roverbyopenstax.com/edx/app/nginx/sites-available/lms /edx/app/nginx/sites-available/
#cp /root/edx-config.roverbyopenstax.com/edx/app/nginx/sites-available/cms /edx/app/nginx/sites-available/

# copy server-vars and any other mods to ansible-related work flows
#cp /root/edx-config.roverbyopenstax.com/edx/app/edx_ansible/*.* /edx/app/edx_ansible/

#sudo service nginx restart

