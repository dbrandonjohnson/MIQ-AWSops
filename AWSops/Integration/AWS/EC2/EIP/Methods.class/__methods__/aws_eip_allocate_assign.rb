###################################
#
# CFME Automate Method: AWS_EIP_Allocate_Assign
#
# By: Brandon Johnson
#
# Notes: This methods allocates an Elastic IP address and associates it with an instance
#
# Inputs:
#
###################################
begin
  # Method for logging
  def log(level, message)
    @method = 'AWS_EIP_Allocate'
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



  # Dialogs Options

  eip_vpc = $evm.root['dialog_eip_vpc']
  log(:info, "vpc true? -> #{eip_vpc}")

  require 'rubygems'
  require 'aws-sdk'

  aws = $evm.vmdb(:ems_amazon).first

  #aws = $evm.root['ext_management_system']
  #log(:info, "AWS: #{aws.inspect}")
  #log(:info, "AWS Virtual Columns: #{aws.virtual_columns_inspect}")
  #aws.methods.sort.each {|method| log(:info, "METHOD: AWS.#{method}")}
  #log(:info, "AWS: #{aws.authentication_userid}")
  #log(:info, "AWS: #{aws.authentication_password}")
  #log(:info, "AWS: Region: #{aws.hostname}")
  vm = $evm.root['vm']

  log(:info, "==========================")
  log(:info, "==========================")
  log(:info, "==========================")



  AWS.config(
      :access_key_id => aws.authentication_userid,
      :secret_access_key => aws.authentication_password
  )

  log(:info, "==========================")
  log(:info, "==========================")
  log(:info, "==========================")


  ec2 = AWS::EC2.new().regions[aws.hostname]
  #log(:info, "Got AWS-SDK connection: #{ec2.inspect}")
  ec2.methods.sort.each {|method| log(:info, "METHOD: Instance.#{method}")}
  log(:info, "Region: #{ec2.name}")

  log(:info, "==========================")
  log(:info, "==========================")
  log(:info, "==========================")


  #eip = ec2.elastic_ips.create()
  #log(:info, "Elastic IP allocated -> #{eip.public_ip}")

  if eip_vpc == 1
    eip = ec2.elastic_ips.create(:vpc => true)
    aws.refresh
  else
    eip = ec2.elastic_ips.create()
    aws.refresh
  end

  public_ip = eip.public_ip


  log(:info, "created an elastic ip address -> #{public_ip}")

  log(:info, "assigning an ip address to instance #{vm.name} -> #{vm.ems_ref}")

  eip.associate :instance => "#{vm.ems_ref}"








  log(:info, "==========================")
  log(:info, "==========================")
  log(:info, "==========================")

  # Exit method
  log(:info, "CFME Automate Method Ended")
  exit MIQ_OK

    # Ruby rescue 
rescue => err
  log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  exit MIQ_ABORT
end
