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
      assign_public_ip :ENABLED
      security_groups [
        Fn::import_value(Fn.sub('${vpc}-SecurityGroup')),
        Fn::if(:RedisStackExists, Fn::import_value(Fn::sub('${redis}-SecurityGroup')), AWS::no_value)
      ]
    end
  end
  task_definition Fn.ref(:EcsTask)
  load_balancers [
    # ECS handles registration of the load balancer target group
    {
      ContainerName: Fn::sub('${AWS::StackName}-flower'),
      ContainerPort: 5555,
      TargetGroupArn: Fn::import_value(Fn.sub('${loadbalancer}-FlowerTargetGroup'))
    },
    {
      ContainerName: Fn::sub('${AWS::StackName}-webserver'),
      ContainerPort: 8080,
      TargetGroupArn: Fn::import_value(Fn.sub('${loadbalancer}-WebserverTargetGroup'))
    },
  ]
end

output :EcsService, Fn::ref(:EcsService), export: Fn::sub('${AWS::StackName}-EcsService')
