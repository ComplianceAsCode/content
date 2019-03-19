# platform = SUSE Linux Enterprise 12

if grep --silent ^solver.upgradeRemoveDroppedPackages /etc/zypp/zypp.conf ; then
        sed -i "s/^solver.upgradeRemoveDroppedPackages.*/solver.upgradeRemoveDroppedPackages=true/g" /etc/zypp/zypp.conf
else
        echo -e "\n# Set solver.upgradeRemoveDroppedPackages to 1 per security requirements" >> /etc/zypp/zypp.conf
        echo "solver.upgradeRemoveDroppedPackages=true" >> /etc/zypp/zypp.conf
fi
