## destination for container logs
resource :LogGroup, 'AWS::Logs::LogGroup' do
  log_group_name Fn::sub('/${AWS::StackName}')
  retention_in_days 30
end

output :LogGroup, Fn::ref(:LogGroup)
