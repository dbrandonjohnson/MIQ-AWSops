###########################################
#
# CFME Automate Method: AWS_ELB_Register_Instance
#
# By: Brandon Johnson
#
# Notes: This method registers an instance an ELB Load Balancer and adds the VM to the associated ELB service in CloudForms
#
# Based on V2 of the AWS SDK
# Inputs: dialog_elb_name (dynamic drop down refr to /#Domain/Integrations/AWS/ELB/Dialogs/AWS_ELB_LoadBalancer_List)
#
###########################################
begin
  # Method for logging
  def log(level, message)
    @method = 'AWS_ELB_Register_Instance'
    $evm.log(level, "#{@method} - #{message}")
  end

  # dump_root
  def dump_root()
    log(:info, "Root:<$evm.root> Begin $evm.root.attributes")
    $evm.root.attributes.sort.each { |k, v| log(:info, "Root:<$evm.root> Attribute - #{k}: #{v}") }
    log(:info, "Root:<$evm.root> End $evm.root.attributes")
    log(:info, "")
  end

  log(:info, "CFME Automate Method Started")

  # dump all root attributes to the log
  dump_root

  vm = $evm.root['vm']
  #getting dialog options

  instanceid = vm.ems_ref
  elb_name = $evm.root['dialog_elb_name']


  log(:info, "==========================")
  log(:info, "==========================")
  log(:info, "==========================")

  require 'rubygems'
  require 'aws-sdk-core'

  awscf = $evm.vmdb(:ems_amazon).first

  #awscf = $evm.root['ext_management_system']
  #log(:info, "AWS: #{awscf.inspect}")
  #log(:info, "AWS Virtual Columns: #{awscf.virtual_columns_inspect}")
  awscf.methods.sort.each {|method| log(:info, "METHOD: AWS.#{method}")}
  log(:info, "AWS: #{awscf.authentication_userid}")
  log(:info, "AWS: #{awscf.authentication_password}")
  log(:info, "AWS: Region: #{awscf.hostname}")

  log(:info, "==========================")
  log(:info, "==========================")
  log(:info, "==========================")


  Aws.config[:credentials] = Aws::Credentials.new(awscf.authentication_userid, awscf.authentication_password)

  elasticloadbalancing = Aws::ElasticLoadBalancing::Client.new(region: "#{awscf.hostname}")


  resp = elasticloadbalancing.register_instances_with_load_balancer(
      # required
      load_balancer_name: "#{elb_name}",
      # required
      instances: [
          {
              instance_id: "#{instanceid}",
          },
      ],
  )

  services = $evm.vmdb('service').all

  for service in services
    log(:info, "Inspect service #{service.inspect}: #{service.name}")
    if service.name == ("ELB: #{elb_name}")
      log(:info, "Found Service; #{service.name}")
      vm.add_to_service(service)
      vm.refresh
      vm.custom_set("ELB_CF_Service", "Yes")
      vm.custom_set("Attached_ELB", elb_name.to_s)
    else
      log(:info, "No match on #{service.name} #{elb_name}")
      vm.custom_set("ELB_CF_Service", "No")
      vm.custom_set("Attached_ELB", elb_name.to_s)
    end
  end


  # Exit method
  log(:info, "CFME Automate Method Ended")
  exit MIQ_OK

    # Ruby rescue 
rescue => err
  log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  exit MIQ_ABORT
end
