###########################################
#
# CFME Automate Method: AWS_ELB_LoadBalancer_List
#
# By: Brandon Johnson
#
# Notes: Get a list of available Elastic Load Balancers
#
# Inputs:
#
###########################################
begin
  # Method for logging
  def log(level, message)
    @method = 'AWS_ELB_LoadBalancer_List'
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


  require 'rubygems'
  require 'aws-sdk-v1'

  aws = $evm.vmdb(:ems_amazon).first

  provider = $evm.root['ext_management_system']
  log(:info, "AWS: #{aws.inspect}")
  log(:info, "AWS Virtual Columns: #{aws.virtual_columns_inspect}")
  aws.methods.sort.each {|method| log(:info, "METHOD: AWS.#{method}")}
  log(:info, "AWS: #{aws.authentication_userid}")
  log(:info, "AWS: #{aws.authentication_password}")
  log(:info, "AWS: Region: #{aws.provider_region}")


  AWS.config(
      :elb_endpoint => "elasticloadbalancing.#{aws.provider_region}.amazonaws.com",
      :access_key_id => aws.authentication_userid,
      :secret_access_key => aws.authentication_password
  )


  elb = AWS::ELB.new()
  log(:info, "Got AWS-SDK connection: #{elb.inspect}")
  elb.methods.sort.each {|method| log(:info, "METHOD: elb.#{method}")}


  lb_hash = {}
  lb_hash[nil] = nil


  for lb in elb.load_balancers
    log(:info, "Available Load Balancers ----> #{lb.name}")
    lb_hash[lb.name] = lb.name
  end

  log(:info, "#{lb_hash}")

  $evm.object["sort_by"] = "description"
  $evm.object["sort_order"] = "ascending"
  $evm.object["data_type"] = "string"
  $evm.object["required"] = "true"
  $evm.object['values'] = lb_hash
  log(:info, "Dynamic drop down values: #{$evm.object['values']}")





  # Exit method
  log(:info, "CFME Automate Method Ended")
  exit MIQ_OK

    # Ruby rescue 
rescue => err
  log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  exit MIQ_ABORT
end
