description 'Public Facing Loadbalancer'

parameter :vpc, type: :String

include_template(
  'loadbalancer/targetgroups.rb',
  'loadbalancer/loadbalancer.rb'
)
