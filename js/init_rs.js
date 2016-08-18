var replicaSetConfig =
{
    _id: "rs0",
    members: [
        {_id: 0, host: "mongo0.service.consul:27017", priority: 2},
        {_id: 1, host: "mongo1.service.consul:27017"},
        {_id: 2, host: "mongo2.service.consul:27017"}
    ]
};

result = rs.initiate(replicaSetConfig);
printjson(result);