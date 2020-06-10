description 'Kookaburra redis cluster'

parameter :vpc,     type: :String

include_template(
  'redis/subnet_group.rb',
  'redis/security_group.rb',
  'redis/replication_group.rb',
)
