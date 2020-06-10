resource :EcsService, 'AWS::ECS::Service', DependsOn: [:EcsCluster, :EcsTask] do
  cluster Fn::ref(:EcsCluster)
  deployment_configuration do
    minimum_healthy_percent 75
    maximum_percent 200
  end
  desired_count 1
  launch_type :FARGATE
  network_configuration do
    awsvpc_configuration do
      subnets Fn::split(',', Fn.import_value(Fn.sub('${vpc}-Subnets')))
#       assign_public_ip :ENABLED
      security_groups [
        Fn::import_value(Fn.sub('${vpc}-SecurityGroup')),
        Fn::if(:RedisStackExists, Fn::import_value(Fn::sub('${redis}-SecurityGroup')), AWS::no_value)
      ]
    end
  end
  task_definition Fn.ref(:EcsTask)
#   load_balancers [
#     {
#       ContainerName: :app,
#       ContainerPort: Fn.ref(:GryphonPort),
#       TargetGroupArn: Fn.import_value(Fn.sub('${lb}-AlbTg'))
#     }
#   ]
end

output :EcsService, Fn::ref(:EcsService), export: Fn::sub('${AWS::StackName}-EcsService')
