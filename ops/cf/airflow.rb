description 'Kookaburra ecs service'

## stack names for imports
parameter :vpc, type: :String
parameter :redis, type: :String

## safe branch name for image tag
parameter :branch, type: :String

## desired count for tasks
parameter :desired, type: :String, default: ''

## returns true if :desired param is not empty
condition :DesiredCount, Fn::not(Fn::equals(Fn::ref(:desired), ''))

## returns true if there is a redis stack
condition :RedisStackExists, Fn::not(Fn::equals(Fn::ref(:redis), ''))

## where to find creds
parameter :ssmenv, type: :String
env = parameters[:ssmenv]
parameter :PostgresUser, type: 'AWS::SSM::Parameter::Value<String>', default: "/kookaburra/DATABASE_USER"
parameter :PostgresPassword, type: 'AWS::SSM::Parameter::Value<String>', default: "/kookaburra/DATABASE_PASSWORD"

include_template(
  'airflow/log_group.rb',
  'airflow/iam_role_exec.rb',
  'airflow/iam_role_task.rb',
  'airflow/ecs_cluster.rb',
  'airflow/ecs_service.rb',
  'airflow/ecs_task.rb',
)
