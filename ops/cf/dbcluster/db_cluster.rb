resource :DbCluster, 'AWS::RDS::DBCluster', DeletionPolicy: :Retain do
  backup_retention_period 7
  d_b_cluster_parameter_group_name Fn::import_value(Fn::sub('${dbparam}-DbClusterParamGroup'))
  d_b_subnet_group_name Fn::import_value(Fn::sub('${dbparam}-SubnetGroup'))
  engine 'aurora-postgresql'
  engine_version '11.6'
  enable_i_a_m_database_authentication true
  port 5432
  preferred_backup_window '05:52-06:22'
  preferred_maintenance_window 'wed:04:37-wed:05:07'
  storage_encrypted true
  vpc_security_group_ids [
    Fn::import_value(Fn::sub('${vpc}-SgDb'))
  ]
  tag :Name, Fn::ref('AWS::StackName')

  ## set the snapshot only if we were passed it as a parameter
  snapshot_identifier Fn::if(:HasSnapshotId, Fn::ref(:snapshotid), Fn::ref('AWS::NoValue'))

  master_username Fn::ref(:dbuser)
  master_user_password Fn::ref(:dbpassword))
end

output :DbCluster,            Fn::ref(:DbCluster)
output :DbClusterAddress,     Fn::get_att(:DbCluster, 'Endpoint.Address')
output :DbClusterPort,        Fn::get_att(:DbCluster, 'Endpoint.Port')
output :DbClusterReadAddress, Fn::get_att(:DbCluster, 'ReadEndpoint.Address')
