## Monkey-patches you may make to change stack behavior.
## Changing these here will affect all stacks.
## You may also define these per-stack in the sub-class for each stack in lib/stacks/.

module Stax
  class Stack < Base

    no_commands do

      ## your application name, will start all stack names
      # def app_name
      #   @_app_name ||= options[:app].empty? ? nil : cfn_safe(options[:app])
      # end

      def ssm_environment
        if Git.branch == 'master'
          @_ssm_environment ||= 'production'
        elsif Git.branch == 'staging'
          @_ssm_environment ||= 'staging'
        else
          @_ssm_environment ||= 'dev'
        end
      end

      ## turn on protection for production stacks
      def cfn_termination_protection
        branch_name == 'master'
      end

    end

  end
end
