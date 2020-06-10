resource :ReplGroup, 'AWS::ElastiCache::ReplicationGroup', DependsOn: [:Sg, :SubnetGroupRedis] do
  replication_group_description Fn::ref('AWS::StackName')
  num_cache_clusters 2
  engine :redis
  engine_version '5.0.4'
  cache_node_type 'cache.t2.micro'
  cache_subnet_group_name Fn::ref(:SubnetGroupRedis)
  security_group_ids [ Fn::ref(:Sg) ]
  at_rest_encryption_enabled false
  transit_encryption_enabled false
  auto_minor_version_upgrade true
  automatic_failover_enabled true
  preferred_maintenance_window 'wed:05:00-wed:07:30'
  snapshot_retention_limit 7
  snapshot_window '01:30-04:30'
end

output :ReplGroup,              Fn::ref(:ReplGroup),                                                                             export: Fn::sub('${AWS::StackName}-ReplGroup')
output :PrimaryEndPointAddress, Fn::get_att(:ReplGroup, 'PrimaryEndPoint.Address'),                                              export: Fn::sub('${AWS::StackName}-PrimaryEndPointAddress')
output :PrimaryEndPointPort,    Fn::get_att(:ReplGroup, 'PrimaryEndPoint.Port'),                                                 export: Fn::sub('${AWS::StackName}-PrimaryEndPointPorts')
output :ReadEndPointAddresses,  Fn::get_att(:ReplGroup, 'ReadEndPoint.Addresses'),                                               export: Fn::sub('${AWS::StackName}-ReadEndPointAddresses')
output :ReadEndPointPorts,      Fn::get_att(:ReplGroup, 'ReadEndPoint.Ports'),                                                   export: Fn::sub('${AWS::StackName}-ReadEndPointPorts')
output :RedisConnection,        Fn::join('', 'redis://', Fn::get_att(:ReplGroup, 'PrimaryEndPoint.Address'), ':', Fn::get_att(:ReplGroup, 'PrimaryEndPoint.Port')),         export: Fn::sub('${AWS::StackName}-RedisConnection')
