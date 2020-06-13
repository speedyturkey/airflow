# Target Group

resource :FlowerTargetGroup, 'AWS::ElasticLoadBalancingV2::TargetGroup' do
  port 5555
  protocol :TCP
  vpc_id Fn.import_value(Fn.sub('${vpc}-VpcId'))
  target_type :ip
end

output :FlowerTargetGroupArn, Fn.ref(:FlowerTargetGroup), export: Fn.sub('${AWS::StackName}-FlowerTargetGroup')
