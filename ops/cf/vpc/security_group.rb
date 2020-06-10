resource :SecurityGroup, 'AWS::EC2::SecurityGroup', DependsOn: :Vpc do
  group_description Fn::ref('AWS::StackName')
  vpc_id Fn::ref(:Vpc)
end

output :SecurityGroup, Fn::ref(:SecurityGroup), export: Fn::sub('${AWS::StackName}-SecurityGroup')
