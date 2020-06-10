description 'Kookaburra aurora cluster'

## stacks for imports
parameter :vpc,     type: :String
parameter :dbparam, type: :String

## get creds from SSM param store
parameter :dbuser, type: 'AWS::SSM::Parameter::Value<String>', default: "/kookaburra/DATABASE_USER"
parameter :dbpassword, type: 'AWS::SSM::Parameter::Value<String>', default: "/kookaburra/DATABASE_PASSWORD"

## snapshot for restore
parameter :snapshotid, type: :String, default: ''
condition :HasSnapshotId, Fn::not(Fn::equals(Fn::ref(:snapshotid), ''))

include_template(
  'dbcluster/db_cluster.rb',
  'dbcluster/db_instances.rb',
)
