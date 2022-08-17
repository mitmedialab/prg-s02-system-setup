LOC_SCHOOL="1"
LOC_HOME="2"
LOC_DEV="3"
echo "Select from the following option:"
echo "[1] School Deployment"
echo "[2] Home Deployment"
echo "[3] DEV Deployment"
read LOCATION

if [ "$LOCATION" = "$LOC_SCHOOL" ]; then
   SWARM_TOKEN="SWMTKN-1-4qtr77cbney2t4f81rj7qlz61fq78l4wyv3infn4d5lz1ct1g1-4ryfnlja84ovm2da412rk0xe2 18.27.79.165:2377"
   SHEET_URL="https://docs.google.com/spreadsheets/d/1LyPBXvrFj7XT9vVZTdyXslW371ttndbsb-SnG8kh-2M/edit?usp=sharing"
elif [ "$LOCATION" = "$LOC_HOME" ]; then
   SWARM_TOKEN="SWMTKN-1-3r1kuhl9wrgka8pce4slulizgo0elx8m81plxsxct31md3tbgd-by06dq1top1x9wfm3mxwn6z5b 18.27.78.195:2377" 
   SHEET_URL="https://docs.google.com/spreadsheets/d/135a5wF63Tt_AUOSR7NvoM1jeysmoccADIUxwsIcF2c0/edit?usp=sharing"
elif [ "$LOCATION" = "$LOC_DEV" ]; then
   SWARM_TOKEN="SWMTKN-1-3mh14xm7y74su3jcoym339t7n562bzossrfn0fksdv5wm2qnxm-ex4dblke9q3os5o2i1cixlv88 18.27.79.58:2377" 
   SHEET_URL="https://docs.google.com/spreadsheets/d/135a5wF63Tt_AUOSR7NvoM1jeysmoccADIUxwsIcF2c0/edit?usp=sharing"   
else
   exit
fi


sudo docker swarm leave 
sudo docker swarm join --token $SWARM_TOKEN 
