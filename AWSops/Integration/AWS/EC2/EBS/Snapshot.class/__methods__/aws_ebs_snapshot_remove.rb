##################################
#
# CFME Automate Method: AWS_EBS_Snapshot_Remove
#
# Notes: This method will remove a specified EBS Snapshot
#
# By: Brandon Johnson
#
# Requires the aws ruby sdk gem (gem aws-sdk)
# Inputs: ebs_device (i.e. /dev/sdc)
#
###################################
begin
  # Method for logging
  def log(level, message)
    @method = 'AWS_EBS_Snapshot_Remove'
    $evm.log(level, "#{@method} - #{message}")
  end

  # dump_root
  def dump_root()
    log(:info, "Root:<$evm.root> Begin $evm.root.attributes")
    $evm.root.attributes.sort.each { |k, v| log(:info, "Root:<$evm.root> Attribute - #{k}: #{v}")}
    log(:info, "Root:<$evm.root> End $evm.root.attributes")
    log(:info, "")
  end

  log(:info, "CFME Automate Method Started")

  # dump all root attributes to the log
  dump_root

  require 'rubygems'
  require 'aws-sdk-v1'

  aws = $evm.vmdb(:ems_amazon).first


  #aws = $evm.root['ext_management_system']
  #log(:info, "AWS: #{aws.inspect}")
  #log(:info, "AWS Virtual Columns: #{aws.virtual_columns_inspect}")
  #aws.methods.sort.each {|method| log(:info, "METHOD: AWS.#{method}")}
  #log(:info, "AWS: #{aws.authentication_userid}")
  #log(:info, "AWS: #{aws.authentication_password}")
  #log(:info, "AWS: Region: #{aws.hostname}")

  log(:info, "==========================")
  log(:info, "==========================")
  log(:info, "==========================")


  vm = $evm.root['vm']
  instanceid = vm.ems_ref

  ebs_device = $evm.root['dialog_ebs_device'].to_s
  snapid = $evm.root['dialog_snapshot_id'].to_s


  AWS.config(
      :access_key_id => aws.authentication_userid,
      :secret_access_key => aws.authentication_password
  )

  log(:info, "==========================")
  log(:info, "==========================")
  log(:info, "==========================")


  ec2 = AWS.ec2 #=> AWS::Instance
  ec2.client #=> AWS::Instance::Client
  ec2.methods.sort.each {|method| log(:info, "METHOD: Instance.#{method}")}


  log(:info, "==========================")
  log(:info, "==========================")
  log(:info, "==========================")



  #attachedvolume = vm.custom_get("Attached_EBSVolume_#{ebs_device}")
  #log(:info, "Removing snapshot #{snapid} associated with this volume: #{attachedvolume} ")

  log(:info, "==========================")
  log(:info, "==========================")
  log(:info, "==========================")

  #Check the volumethe volume
  #volume = ec2.volumes[attachedvolume]
  #log(:info, "#{volume.exists?}")

  #delete the snapshot
  snapshot = ec2.snapshots["#{snapid}"]
  snapshot.delete




  log(:info, "==========================")
  log(:info, "==========================")
  log(:info, "==========================")


  #Add the snapshot id to a custom field
  log(:info, "Removing Snapshot #{snapid} from VM:<#{vm.name}> #{instanceid} and removing the custom attributes")
  vm.custom_set("EBS_Snap_ID_#{ebs_device}_#{snapid}", nil)
  vm.custom_set("EBS_SnapDescription_#{snapid}", nil)


  # Exit method
  log(:info, "CFME Automate Method Ended")
  exit MIQ_OK

    # Ruby rescue
rescue => err
  log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  exit MIQ_ABORT
end
