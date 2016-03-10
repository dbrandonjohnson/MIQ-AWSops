###########################################
#
# CFME Automate Method: AWS_ELB_LoadBalancer_Create
#
# By: Brandon Johnson
#
# Notes: Create an Elastic Load Balancer as a Service in CloudForms
#
# Inputs: dialog_az_name, dialog_elb_name, dialog_elb_port, dialog_elb_protocol, dialog_ec2_protocol
#
###########################################
begin
  # Method for logging
  def log(level, message)
    @method = 'AWS_ELB_LoadBalancer_Create'
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


  az_name = $evm.root['dialog_az_name'].to_s


  elb_name = $evm.root['dialog_elb_name'].to_s
  elb_port = $evm.root['dialog_elb_port'].to_i
  elb_protocol = $evm.root['dialog_elb_protocol'].to_s

  ec2_port = $evm.root['dialog_ec2_port'].to_i
  ec2_protocol = $evm.root['dialog_ec2_protocol'].to_s



  require 'rubygems'
  require 'aws-sdk-v1'

  aws = $evm.vmdb(:ems_amazon).first

  # aws = $evm.root['ext_management_system']
  # #log(:info, "AWS: #{aws.inspect}")
  # #log(:info, "AWS Virtual Columns: #{aws.virtual_columns_inspect}")
  aws.methods.sort.each {|method| log(:info, "METHOD: AWS.#{method}")}
  log(:info, "AWS: #{aws.authentication_userid}")
  log(:info, "AWS: #{aws.authentication_password}")
  log(:info, "=============================")
  log(:info, "AWS: Region: #{aws.provider_region}")
  log(:info, "=============================")




  AWS.config(
      :elb_endpoint => "elasticloadbalancing.#{aws.provider_region}.amazonaws.com",
      :access_key_id => aws.authentication_userid,
      :secret_access_key => aws.authentication_password
  )


  elb = AWS::ELB.new()



  log(:info, "=============================")
  log(:info, "Got AWS-SDK connection: #{elb.inspect}")
  log(:info, "=============================")
  elb.methods.sort.each {|method| log(:info, "METHOD: elb.#{method}")}


  service_template_provision_task = $evm.root['service_template_provision_task']
  service = service_template_provision_task.destination
  log(:info, "=============================")
  log(:info, "Detected Service:<#{service.name}> Id:<#{service.id}> Tasks:<#{service_template_provision_task.miq_request_tasks.count}>")
  log(:info, "=============================")
  log(:info, "DEBUG: #{service_template_provision_task.inspect}")
  log(:info, "=============================")

  loadbalancer = elb.load_balancers.create("#{elb_name}",
                                           :availability_zones => (az_name),
                                           :listeners => [{
                                                              :port => elb_port,
                                                              :protocol => :"#{elb_protocol}",
                                                              :instance_port => ec2_port,
                                                              :instance_protocol => :"#{ec2_protocol}",
                                                          }])
  log(:info, "=============================")
  log(:info, "#{loadbalancer} has been created")
  log(:info, "=============================")
  service.name = "ELB: #{elb_name}"
  service.description = "ELB Load Balancer - Availability Zones #{az_name}"


  # Exit method
  log(:info, "CFME Automate Method Ended")
  exit MIQ_OK

    # Ruby rescue 
rescue => err
  log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  exit MIQ_ABORT
end	
