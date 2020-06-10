resource :EcsCluster, 'AWS::ECS::Cluster' do
  cluster_name Fn::ref('AWS::StackName')
end

output :EcsCluster, Fn::ref(:EcsCluster), export: Fn::sub('${AWS::StackName}-EcsCluster')
