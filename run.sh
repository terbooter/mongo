mkdir -p /keyfiles &&
echo $MONGO_KEY > /keyfiles/key &&
chmod 400 /keyfiles/key &&
mongod --config /etc/mongod.conf;