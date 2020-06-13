resource :PublicLoadBalancer, 'AWS::ElasticLoadBalancingV2::LoadBalancer' do
  scheme 'internet-facing'
  subnets Fn.split(',', Fn.import_value(Fn.sub('${vpc}-Subnets')))
  type :network
end

resource :FlowerLoadBalancerListener, 'AWS::ElasticLoadBalancingV2::Listener', DependsOn: :FlowerTargetGroup do
  default_actions [
    {
      TargetGroupArn: Fn.ref(:FlowerTargetGroup),
      Type: 'forward'
    }
  ]
  load_balancer_arn Fn.ref(:PublicLoadBalancer)
  port 5555
  protocol :TCP
end

resource :WebserverLoadBalancerListener, 'AWS::ElasticLoadBalancingV2::Listener', DependsOn: :WebserverTargetGroup do
  default_actions [
    {
      TargetGroupArn: Fn.ref(:WebserverTargetGroup),
      Type: 'forward'
    }
  ]
  load_balancer_arn Fn.ref(:PublicLoadBalancer)
  port 8080
  protocol :TCP
end

output :FlowerLoadBalancerListenerArn, Fn.ref(:FlowerLoadBalancerListener)
output :LoadBalancerDNS,              Fn.get_att(:PublicLoadBalancer, :DNSName)
