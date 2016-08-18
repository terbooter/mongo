if [ ! -f /data/mongo_root_password ] ; then
    echo "*** Generating password for root mongo user ***"
    echo $(pwgen -s -1 12) > /data/mongo_root_password
else
    echo "*** File /data/mongo_root_password found ***"
fi

# make js file with root_password variable to load in mongo shell
echo "var root_password = '"$(cat /data/mongo_root_password)"';"> /mongo_root_password.js;
# make bash script to quick mongo shell login as root
echo "mongo -u 'root' -p '"$(cat /data/mongo_root_password)"' --authenticationDatabase 'admin'" > /mongo.sh;
chmod +x /mongo.sh;

mkdir -p /keyfiles &&
echo $MONGO_KEY > /keyfiles/key &&
chmod 400 /keyfiles/key &&
mongod --config /etc/mongod.conf;