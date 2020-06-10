resource :EcsTask, 'AWS::ECS::TaskDefinition', DependsOn: [:IamRoleExec, :IamRoleTask, :LogGroup] do
  cpu 2048 # 256 512 1024 2048 4096
  memory 4096 # 2-8 times cpu
  family Fn::ref('AWS::StackName')
  requires_compatibilities [ :EC2 ]
  execution_role_arn Fn::get_att(:IamRoleExec, :Arn)
  task_role_arn Fn::get_att(:IamRoleTask, :Arn)
  network_mode :awsvpc
  container_definitions [
    # Scheduler
    {
      Name: Fn::sub('${AWS::StackName}-scheduler'),
      Command: ['scheduler'],
      Environment: [
        {"Name": "EXECUTOR", "Value": "Celery"},
        {"Name": "LOAD_EX", "Value": "N"},
        {"Name": "CONFIG", "Value": "DEVELOPMENT"},
        {"Name": "FERNET_KEY", "Value": "bzSmA8ttBWWguJd-cfIYL7fN_v_9uRbf_MBUxYKML-U="},
        {"Name": "REDIS_HOST", "Value": Fn::import_value(Fn.sub('${redis}-PrimaryEndPointAddress'))},
        {"Name": "POSTGRES_USER", "Value": Fn::ref(:PostgresUser)},
        {"Name": "POSTGRES_PASSWORD", "Value": Fn::ref(:PostgresPassword)},
        {"Name": "POSTGRES_HOST", "Value": Fn::import_value(Fn.sub('${dbcluster}-Endpoint.Address'))},
      ],
      Image: Fn::sub('${AWS::AccountId}.dkr.ecr.${AWS::Region}.amazonaws.com/kookaburra:${branch}'),
      MemoryReservation: 1024,
      LogConfiguration: {
        LogDriver: :awslogs,
        Options: {
          'awslogs-group'         => Fn::ref(:LogGroup),
          'awslogs-region'        => Fn::ref('AWS::Region'),
          'awslogs-stream-prefix' => Fn::ref('AWS::StackName'),
        }
      }
    },
    # Worker
    {
      Name: Fn::sub('${AWS::StackName}-worker'),
      Environment: [
        {"Name": "EXECUTOR", "Value": "Celery"},
        {"Name": "LOAD_EX", "Value": "N"},
        {"Name": "CONFIG", "Value": "DEVELOPMENT"},
        {"Name": "FERNET_KEY", "Value": "bzSmA8ttBWWguJd-cfIYL7fN_v_9uRbf_MBUxYKML-U="},
        {"Name": "REDIS_HOST", "Value": Fn::import_value(Fn.sub('${redis}-PrimaryEndPointAddress'))},
        {"Name": "POSTGRES_USER", "Value": Fn::ref(:PostgresUser)},
        {"Name": "POSTGRES_PASSWORD", "Value": Fn::ref(:PostgresPassword)},
        {"Name": "POSTGRES_HOST", "Value": Fn::import_value(Fn.sub('${dbcluster}-Endpoint.Address'))},
      ],
      Image: Fn::sub('${AWS::AccountId}.dkr.ecr.${AWS::Region}.amazonaws.com/kookaburra:${branch}'),
      MemoryReservation: 1024,
      LogConfiguration: {
        LogDriver: :awslogs,
        Options: {
          'awslogs-group'         => Fn::ref(:LogGroup),
          'awslogs-region'        => Fn::ref('AWS::Region'),
          'awslogs-stream-prefix' => Fn::ref('AWS::StackName'),
        }
      }
    },
    # Webserver
    {
      Name: Fn::sub('${AWS::StackName}-webserver'),
      Command: ['webserver'],
      Environment: [
        {"Name": "EXECUTOR", "Value": "Celery"},
        {"Name": "LOAD_EX", "Value": "N"},
        {"Name": "CONFIG", "Value": "DEVELOPMENT"},
        {"Name": "FERNET_KEY", "Value": "bzSmA8ttBWWguJd-cfIYL7fN_v_9uRbf_MBUxYKML-U="},
        {"Name": "REDIS_HOST", "Value": Fn::import_value(Fn.sub('${redis}-PrimaryEndPointAddress'))},
        {"Name": "POSTGRES_USER", "Value": Fn::ref(:PostgresUser)},
        {"Name": "POSTGRES_PASSWORD", "Value": Fn::ref(:PostgresPassword)},
        {"Name": "POSTGRES_HOST", "Value": Fn::import_value(Fn.sub('${dbcluster}-Endpoint.Address'))},
      ],
      Image: Fn::sub('${AWS::AccountId}.dkr.ecr.${AWS::Region}.amazonaws.com/kookaburra:${branch}'),
      MemoryReservation: 1024,
      LogConfiguration: {
        LogDriver: :awslogs,
        Options: {
          'awslogs-group'         => Fn::ref(:LogGroup),
          'awslogs-region'        => Fn::ref('AWS::Region'),
          'awslogs-stream-prefix' => Fn::ref('AWS::StackName'),
        }
      },
      PortMappings: [
        {"ContainerPort": 8080}
      ]
    },
    # Flower
    {
      Name: Fn::sub('${AWS::StackName}-flower'),
      Command: ['flower'],
      Environment: [
        {"Name": "EXECUTOR", "Value": "Celery"},
        {"Name": "REDIS_HOST", "Value": Fn::import_value(Fn.sub('${redis}-PrimaryEndPointAddress'))},
        {"Name": "POSTGRES_USER", "Value": Fn::ref(:PostgresUser)},
        {"Name": "POSTGRES_PASSWORD", "Value": Fn::ref(:PostgresPassword)},
        {"Name": "POSTGRES_HOST", "Value": Fn::import_value(Fn.sub('${dbcluster}-Endpoint.Address'))},
      ],
      Image: Fn::sub('${AWS::AccountId}.dkr.ecr.${AWS::Region}.amazonaws.com/kookaburra:${branch}'),
      MemoryReservation: 1024,
      LogConfiguration: {
        LogDriver: :awslogs,
        Options: {
          'awslogs-group'         => Fn::ref(:LogGroup),
          'awslogs-region'        => Fn::ref('AWS::Region'),
          'awslogs-stream-prefix' => Fn::ref('AWS::StackName'),
        }
      },
      PortMappings: [
        {"HostPort": 5555, "ContainerPort": 5555}
      ]
    }
  ]
end

output :EcsTask, Fn::ref(:EcsTask)
