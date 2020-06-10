resource :SubnetGroupRedis, 'AWS::ElastiCache::SubnetGroup' do
  description Fn::ref('AWS::StackName')
  subnet_ids Fn::split(',', Fn::import_value(Fn::sub('${vpc}-Subnets')))
end
