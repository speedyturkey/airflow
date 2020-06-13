description 'Public Facing Loadbalancer'

parameter :vpc, type: :String
parameter :airflow, type: :String

include_template(
  'loadbalancer/targetgroups.rb',
  'loadbalancer/loadbalancer.rb'
)
