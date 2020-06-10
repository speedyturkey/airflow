2.times do |i|
  resource "DbInstance#{i}", 'AWS::RDS::DBInstance', DependsOn: :DbCluster, DeletionPolicy: :Retain do
    db_cluster_identifier Fn::ref(:DbCluster)
    d_b_instance_class 'db.t3.medium'
    d_b_subnet_group_name Fn::import_value(Fn::sub('${dbparam}-SubnetGroup'))
    engine 'aurora-postgresql'
    delete_automated_backups false
    publicly_accessible true
    tag :Name, Fn::ref('AWS::StackName')
  end
end
