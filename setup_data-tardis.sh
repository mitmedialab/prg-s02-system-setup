CONTAINER_NAME="data-tardis"
IMAGE_NAME="docker-registry.jibo.media.mit.edu:5000/mitprg/prg-data-tardis:20250321"

while true; do
    read -p "Proceed with setting up data-tardis docker container? [Y/n]: " yn
    case $yn in
        [Nn]* ) INSTALL=false; echo "Please run ./setup_data-tardis.sh later"; break;;
        [Yy]*|"" ) echo "Okay, setting up data-tardis docker container."; break;;
        * ) echo "Please answer yes or no.";;
    esac
done

if $INSTALL_DATA_TARDIS_CONTAINER; then
    docker rm -f $CONTAINER_NAME
    docker pull "$IMAGE_NAME"
    docker run -d --restart=unless-stopped --name="$CONTAINER_NAME" -p 1963:1963 --privileged -v /dev:/dev --env ETCO_synology_password="9^jvH%5cU6#E" --env HOST_HOSTNAME="`hostname`" --env ETCO_delete_after_upload=1 --mount type=bind,source=/media,target=/media,bind-propagation=shared "$IMAGE_NAME"
fi
