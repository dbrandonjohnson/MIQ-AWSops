#################################
#
# CFME Automate Method: AWS_EC2_Create_AMI_From_Instance
#
# By: Brandon Johnson
#
# Notes: This method will create an Amazon Machine Image from the selected Instance
#
# Inputs:
#
#################################
begin
  # Method for logging
  def log(level, message)
    @method = 'Automate_RubyTemplate'
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
  instanceid = vm.ems_ref
  ami_name = $evm.root['dialog_ami_name']

  log(:info, "==========================")
  log(:info, "==========================")
  log(:info, "==========================")

  require 'rubygems'
  require 'aws-sdk-v1'

  aws = $evm.vmdb(:ems_amazon).first

  #aws = $evm.root['ext_management_system']
  #log(:info, "AWS: #{aws.inspect}")
  #log(:info, "AWS Virtual Columns: #{aws.virtual_columns_inspect}")
  aws.methods.sort.each {|method| log(:info, "METHOD: AWS.#{method}")}
  #log(:info, "AWS: #{aws.authentication_userid}")
  #log(:info, "AWS: #{aws.authentication_password}")
  #log(:info, "AWS: Region: #{aws.hostname}")

  log(:info, "==========================")
  log(:info, "==========================")
  log(:info, "==========================")

  AWS.config(
      :access_key_id => aws.authentication_userid,
      :secret_access_key => aws.authentication_password
  )


  ec2 = AWS::EC2.new().regions[aws.hostname]
  #log(:info, "Got AWS-SDK connection: #{ec2.inspect}")
  ec2.methods.sort.each {|method| log(:info, "METHOD: Instance.#{method}")}
  log(:info, "Region: #{ec2.name}")


  log(:info, "==========================")
  log(:info, "==========================")
  log(:info, "==========================")


  log(:info, "Creating an ami based on #{instnaceid} with #{ami_name}")

  ec2.instances["#{instanceid}"].create_image(ami_name)
  aws.refresh



  # Exit method
  log(:info, "CFME Automate Method Ended")
  exit MIQ_OK

    # Ruby rescue 
rescue => err
  log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  exit MIQ_ABORT
end
