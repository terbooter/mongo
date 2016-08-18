print("Create admin users on primary node");
db = db.getSiblingDB('admin');

load("/mongo_root_password.js");
print("ROOT PASSWORD=" + root_password);
 db.createUser( {
 user: "root",
 pwd: root_password,
 roles: [ { role: "root", db: "admin" } ]
 });
