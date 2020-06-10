## allow access to db
resource :SgDb, 'AWS::EC2::SecurityGroup', DependsOn: :Vpc do
  group_description Fn::sub('${AWS::StackName} db access')
  vpc_id Fn::ref(:Vpc)
  security_group_ingress [
    { CidrIp: '100.36.185.63/32', IpProtocol: :tcp, FromPort: 5432, ToPort: 5432 }, # ric
    { CidrIp: '108.31.47.47/32',  IpProtocol: :tcp, FromPort: 5432, ToPort: 5432 }, # billy
  ]
  security_group_egress [
    { CidrIp: '0.0.0.0/0', IpProtocol: '-1', FromPort: 0, ToPort: 0 }
  ]
  tag :Name, Fn::ref('AWS::StackName')
end

## separate resource so we can point sg to itself
resource :SgDbIngress, 'AWS::EC2::SecurityGroupIngress', DependsOn: :SgDb do
  group_id Fn::ref(:SgDb)
  ip_protocol :tcp
  from_port 5432
  to_port 5432
  source_security_group_id Fn::ref(:SgDb)
end

output :SgDb, Fn::ref(:SgDb), export: Fn::sub('${AWS::StackName}-SgDb')
