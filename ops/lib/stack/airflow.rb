module Stax
  class Airflow < Stack
    include Ecs, Logs

    no_commands do
      def cfn_parameters
        super.merge(
          branch: branch_name,
          ssmenv: ssm_environment,
        )
      end
    end

  end
end
