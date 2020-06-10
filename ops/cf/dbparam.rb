description 'Kookaburra db params'

parameter :vpc, type: :String

include_template(
  'dbparam/subnet_group.rb',
  'dbparam/db_cluster_param_group.rb',
)
