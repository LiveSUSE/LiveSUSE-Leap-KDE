#!/bin/sh

echo "#====================================="
echo "# Setting up KDM4 theme               "
echo "#-------------------------------------"

# Enable theme
sed -i 's/DISPLAYMANAGER_KDM_THEME=.*/DISPLAYMANAGER_KDM_THEME=\"studio\"/g' /etc/sysconfig/displaymanager

if [ -d "/usr/share/kde4/" ] && [ -d "/etc/kde4/" ]; then
	# Enable greeter theme
	sed -i 's|^#UseTheme=.*|UseTheme=true|g' /usr/share/kde4/config/kdm/kdmrc
	sed -i 's|^#Theme=.*|Theme=/usr/share/kde4/apps/kdm/themes/studio|g' /usr/share/kde4/config/kdm/kdmrc
fi
