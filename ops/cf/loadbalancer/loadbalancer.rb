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

output :FlowerLoadBalancerListenerArn, Fn.ref(:FlowerLoadBalancerListener)
output :LoadBalancerDNS,              Fn.get_att(:PublicLoadBalancer, :DNSName)
