############################################
#
# CFME Automate Method: AWS_ELB_AvailabilityZone_Add
#
# By: Brandon Johnson
#
# Notes: Adds a availability zone to a ELB LoadBalancer
#
# Inputs:
#
############################################
begin
  # Method for logging
  def log(level, message)
    @method = 'AWS_ELB_AvailabilityZone_Add'
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

  services = $evm.root['service']
  az_name = $evm.root['dialog_az_name'].to_s

  require 'rubygems'
  require 'aws-sdk'

  aws = $evm.vmdb(:ems_amazon).first

  #aws = $evm.root['ext_management_system']
  #log(:info, "AWS: #{aws.inspect}")
  #log(:info, "AWS Virtual Columns: #{aws.virtual_columns_inspect}")
  #aws.methods.sort.each {|method| log(:info, "METHOD: AWS.#{method}")}
  #log(:info, "AWS: #{aws.authentication_userid}")
  #log(:info, "AWS: #{aws.authentication_password}")
  log(:info, "AWS: Region: #{aws.provider_region}")


  AWS.config(
      :elb_endpoint => "elasticloadbalancing.#{aws.provider_region}.amazonaws.com",
      :access_key_id => aws.authentication_userid,
      :secret_access_key => aws.authentication_password
  )


  sn = services.name.sub!(/^ELB\: /, '')
  log(:info, "name of the service associated with the ELB in Amazon - #{sn}")

  load_balancer = AWS::ELB.new.load_balancers[sn]
  log(:info, "Got AWS-SDK connection: #{load_balancer.inspect}")
  load_balancer.methods.sort.each {|method| log(:info, "METHOD: load_balancer.#{method}")}


  load_balancer.availability_zones.enable("#{az_name}")
  log(:info, "Additional Availability Zone set: #{az_name}")


  services.description = "ELB Load Balancer Availability Zones: "
  for zone in zones
    log(:info, "The load balancer belgons to the following zones: #{zone.name}")
    sd = services.description
    services.description = "#{sd} #{zone.name}"
  end
  log(:info, "#{services.description}")

  # Exit method
  log(:info, "CFME Automate Method Ended")
  exit MIQ_OK

    # Ruby rescue 
rescue => err
  log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  exit MIQ_ABORT
end
