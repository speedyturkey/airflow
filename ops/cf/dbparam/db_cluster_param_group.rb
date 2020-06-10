resource :DbClusterParamGroup, 'AWS::RDS::DBClusterParameterGroup' do
  description Fn::ref('AWS::StackName')
  family 'aurora-postgresql11'
  Parameters(
    {
      'rds.logical_replication': 1,
      'rds.force_ssl': 1
    }
  )
end

output :DbClusterParamGroup, Fn::ref(:DbClusterParamGroup), export: Fn::sub('${AWS::StackName}-DbClusterParamGroup')
