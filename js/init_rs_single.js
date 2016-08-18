var replicaSetConfig =
{
    _id: "rs0",
    members: [
        {_id: 0, host: "mongo0.service.consul:27017", priority: 2}
    ]
};

result = rs.initiate(replicaSetConfig);
printjson(result);