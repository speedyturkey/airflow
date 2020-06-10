resource :Sg, 'AWS::EC2::SecurityGroup' do
  group_description Fn::ref('AWS::StackName')
  vpc_id Fn::import_value(Fn::sub('${vpc}-VpcId'))
  security_group_ingress [
    { CidrIp: Fn::import_value(Fn::sub('${vpc}-VpcCidr')), IpProtocol: '-1', FromPort: 6379, ToPort: 6379 }
  ]
  security_group_egress [
    { CidrIp: '0.0.0.0/0', IpProtocol: '-1', FromPort: 0, ToPort: 0 }
  ]
  tag :Name, Fn::ref('AWS::StackName')
end

## separate resource so we can point sg to itself
resource :SgIngress, 'AWS::EC2::SecurityGroupIngress', DependsOn: :Sg do
  group_id Fn::ref(:Sg)
  ip_protocol :tcp
  from_port 6379
  to_port 6379
  source_security_group_id Fn::ref(:Sg)
end

output :SecurityGroup, Fn::ref(:Sg), export: Fn::sub('${AWS::StackName}-SecurityGroup')
