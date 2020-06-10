description 'Kookaburra VPC'

include_template(
  'vpc/vpc.rb',
  'vpc/subnets.rb',
  'vpc/security_group.rb',
  'vpc/sg_db.rb',
)
