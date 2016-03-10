begin
  @method = "AWS_EC2_List_AvailZone"

  def log(level, msg)
    $evm.log(level, "<#{@method}>:<#{level.downcase}>: #{msg}")
  end

  def dump_root()
    log(:info, "Root:<$evm.root> Begin $evm.root.attributes")
    $evm.root.attributes.sort.each { |k, v| log(:info, "Root:<$evm.root> Attribute - #{k}: #{v}")}
    log(:info, "Root:<$evm.root> End $evm.root.attributes")
    log(:info, "")
  end

  log(:info, "Being Automate Method")

  dump_root()

  require 'aws-sdk'

  aws = $evm.vmdb(:ems_amazon).first

  #aws = $evm.root['ext_management_system']
  log(:info, "AWS: #{aws.inspect}")
  log(:info, "AWS Virtual Columns: #{aws.virtual_columns_inspect}")
  aws.methods.sort.each {|method| log(:info, "METHOD: AWS.#{method}")}
  log(:info, "AWS: #{aws.authentication_userid}")
  log(:info, "AWS: #{aws.authentication_password}")
  log(:info, "AWS: Region: #{aws.hostname}")

  AWS.config(
      :access_key_id => aws.authentication_userid,
      :secret_access_key => aws.authentication_password
  )

  ec2 = AWS::EC2.new().regions[aws.hostname]
  log(:info, "Got AWS-SDK connection: #{ec2.inspect}")
  ec2.methods.sort.each {|method| log(:info, "METHOD: Instance.#{method}")}
  log(:info, "Region: #{ec2.name}")

  az_hash = {}
  az_hash[nil] = nil


  for az in ec2.availability_zones
    log(:info, "#{aws.hostname} -> #{az.inspect}")
    az_hash[az.name] = az.name
  end

  $evm.object["sort_by"] = "description"
  $evm.object["sort_order"] = "ascending"
  $evm.object["data_type"] = "string"
  $evm.object["required"] = "true"
  $evm.object['values'] = az_hash
  log(:info, "Dynamic drop down values: #{$evm.object['values']}")


  log(:info, "Exit Automate Method")


rescue => err
  log(:error, "#{err.class} [#{err}] #{err.backtrace.join("\n")}")
  exit MIQ_STOP
end
