CloudFormation {
  
  Description "Linux Kibana Stack"

  Parameter("KeyName") {
    Description 'Name of an existing EC2 KeyPair to enable SSH access to the instances'
    Type "String"
  }

  Parameter("EnvironmentName") {
    Description 'Name applied to all resources within the stack'
    ConstraintDescription 'must be a valid environment name'
    Type "String"
  }

  Parameter("StackType") {
    Description 'Stack type'
    ConstraintDescription 'must be a valid stack type'
    Type "String"
    Default "Kibana Cluster"
  }

  Parameter("KibanaVersion") {
    Description 'Kibana Version'
    ConstraintDescription 'must be a valid Kibana version'
    Type "String"
    Default "3.1.0"
  }

  Parameter("KibanaHostname") {
    Description 'Kibana Hostname'
    ConstraintDescription 'must be a valid hostname'
    Type "String"
  }

  Parameter("KibanaDashboardUser") {
    Description 'Kibana Dashboard User'
    ConstraintDescription 'must be a valid user'
    Type "String"
  }

  Parameter("KibanaDashboardPassword") {
    Description 'Kibana Hostname'
    Type "String"
    NoEcho "true"
    AllowedPattern "[a-zA-Z0-9]*"
    ConstraintDescription "must contain only alphanumeric characters."
  }

  Parameter("EsHostname") {
    Description 'Elasticsearch Hostname'
    ConstraintDescription 'must be a valid hostname'
    Type "String"
  }

  Parameter("EC2InstanceType") {
    Description 'EC2 instance type'
    ConstraintDescription 'must be a valid EC2 instance type'
    Type "String"
    Default "t2.medium"
    AllowedValues ['t1.micro', 't2.micro', 't2.small', 't2.medium', 'm1.small', 'm1.medium',
                   'm1.large', 'm1.xlarge', 'm3.medium', 'm3.large', 'm3.xlarge', 'm3.2xlarge',
                   'c3.large', 'c3.xlarge', 'c3.2xlarge', 'c3.4xlarge', 'c3.8xlarge']
  }

  Parameter("VpcId") {
    Description 'VPC to deploy network resource into'
    Type "String"
    AllowedPattern "vpc-[a-zA-Z0-9]{8}"
  }

  Parameter("SubnetAz1") {
    Description 'Private Subnet within AZ 1 to deploy instances'
    Type "String"
    AllowedPattern "subnet-[a-zA-Z0-9]{8}"
  }

  Parameter("SubnetAz2") {
    Description 'Private Subnet within AZ 2 to deploy instances'
    Type "String"
    AllowedPattern "subnet-[a-zA-Z0-9]{8}"
  }

  Parameter("PubSubnetAz1") {
    Description 'Public Subnet within AZ 1 to deploy Kibana ELB'
    Type "String"
    AllowedPattern "subnet-[a-zA-Z0-9]{8}"
  }

  Parameter("PubSubnetAz2") {
    Description 'Public Subnet within AZ 2 to deploy Kibana ELB'
    Type "String"
    AllowedPattern "subnet-[a-zA-Z0-9]{8}"
  }

  Parameter("DnsResolverOverride"){
    Description "Comma-delimited list of one or more DNS resolver IP's"
    Type  "String"
    Default ""
  }

  Parameter("PrimaryVolumeSize"){
    Description 'Primary Volume Size in Gb'
    Type "Number"
    MinValue 1
    MaxValue 1000
    Default 50
    ConstraintDescription "must be between 1 and 750."
  }

  Parameter("MinInstances") {
    Description 'Minimum number of Kibana instances'
    Type "Number"
    Default 2
    MinValue 1
    MaxValue 4
    ConstraintDescription "must be between 1 and 4."
  }

  Parameter("MaxInstances") {
    Description 'Maximum number of Kibana instances'
    Type "Number"
    Default 2
    MinValue 1
    MaxValue 8
    ConstraintDescription "must be between 1 and 8."
  }

  Parameter("HealthCheckUri"){
    Description 'Elb Health Check Uri'
    Type "String"
    Default "/"
    ConstraintDescription "must be a valid URI"
  }

  Parameter("HealthCheckPort"){
    Description 'Elb Health Check Port'
    Type "Number"
    Default 80
    MinValue 1
    MaxValue 65535
    ConstraintDescription "must be between 1 and 65535."
  }

  Parameter("Project") {
    Description 'Project name'
    Type "String"
  }

  Parameter("Owner") {
    Description 'Stack owner'
    ConstraintDescription 'must be a valid email address'
    Type "String"
  }

  Mapping('AWSEC2RegionArch2AMI', {
      "us-east-1"      => { "32" => :NOT_YET_SUPPORTED, '64' => :NOT_YET_SUPPORTED, "64HVM" => "ami-34842d5c" },
      "us-west-1"      => { "32" => :NOT_YET_SUPPORTED, "64" => :NOT_YET_SUPPORTED, "64HVM" => "ami-dba8a19e" },
      "us-west-2"      => { "32" => :NOT_YET_SUPPORTED, "64" => :NOT_YET_SUPPORTED, "64HVM" => "ami-8586c6b5" },
      "eu-west-1"      => { "32" => :NOT_YET_SUPPORTED, "64" => :NOT_YET_SUPPORTED, "64HVM" => "ami-768e2901" },
      "ap-southeast-1" => { "32" => :NOT_YET_SUPPORTED, "64" => :NOT_YET_SUPPORTED, "64HVM" => "ami-d2e1c580" },
      "ap-southeast-2" => { "32" => :NOT_YET_SUPPORTED, "64" => :NOT_YET_SUPPORTED, "64HVM" => "ami-fb4724c1" },
      "ap-northeast-1" => { "32" => :NOT_YET_SUPPORTED, "64" => :NOT_YET_SUPPORTED, "64HVM" => "ami-45072844" },
      "sa-east-1"      => { "32" => :NOT_YET_SUPPORTED, "64" => :NOT_YET_SUPPORTED, "64HVM" => "ami-936cc68e" }
  })

  Mapping('AWSEC2InstanceType2Arch', {
      't1.micro'  => { :Arch => '64HVM' },
      't2.micro'  => { :Arch => '64HVM' },
      't2.small'  => { :Arch => '64HVM' },
      't2.medium'  => { :Arch => '64HVM' },
      'm1.small'  => { :Arch => '64HVM' },
      'm1.medium'  => { :Arch => '64HVM' },
      'm1.large'  => { :Arch => '64HVM' },
      'm1.xlarge'  => { :Arch => '64HVM' },
      'm3.medium'  => { :Arch => '64HVM' },
      'm3.large'  => { :Arch => '64HVM' },
      'm3.xlarge'  => { :Arch => '64HVM' },
      'm3.2xlarge'  => { :Arch => '64HVM' },
      'c3.large'  => { :Arch => '64HVM' },
      'c3.xlarge'  => { :Arch => '64HVM' },
      'c3.2xlarge'  => { :Arch => '64HVM' },
      'c3.4xlarge'  => { :Arch => '64HVM' },
      'c3.8xlarge'  => { :Arch => '64HVM' }
  })

  CloudFormation_WaitConditionHandle("WaitHandle") {}

  CloudFormation_WaitCondition("WaitCondition") {
    Handle Ref("WaitHandle")
    Timeout 1200
  }

  IAM_Role("InstanceRole") {
    AssumeRolePolicyDocument({
      :Statement => [{
        :Effect => 'Allow',
        :Principal => {
          :Service => [ 'ec2.amazonaws.com' ]
        },
        :Action => [ 'sts:AssumeRole' ]
      }]
    })
    Path '/'
    Policies [ ]
  }

  IAM_InstanceProfile("InstanceProfile") {
    Path '/'
    Roles [ Ref("InstanceRole") ]
    DependsOn("InstanceRole")
  }

  EC2_SecurityGroup("LinuxKibanaSg") {
    GroupDescription "Kibana Instances Security Group"
    VpcId Ref("VpcId")
  }

  EC2_SecurityGroup("ExternalKibanaElbSg") {
    GroupDescription "External Kibana Elastic Load Balancer Security Group"
    VpcId Ref("VpcId")
  }

  EC2_SecurityGroupIngress("ExternalElbAnyKibana") {
    GroupId Ref("ExternalKibanaElbSg")
    IpProtocol "tcp"
    FromPort 80
    ToPort 80
    CidrIp "0.0.0.0/0"
  }

  EC2_SecurityGroupIngress("ExternalElbLinuxKibana") {
    GroupId Ref("LinuxKibanaSg")
    IpProtocol "tcp"
    FromPort 80
    ToPort 80
    SourceSecurityGroupId Ref("ExternalKibanaElbSg")
  }

  EC2_SecurityGroupIngress("LinuxKibanaAnySsh") {
    GroupId Ref("LinuxKibanaSg")
    IpProtocol "tcp"
    FromPort 22
    ToPort 22
    CidrIp "0.0.0.0/0"
  }
  
  EC2_SecurityGroupIngress("LinuxKibanaAnyKibana") {
    GroupId Ref("LinuxKibanaSg")
    IpProtocol "tcp"
    FromPort 80
    ToPort 80
    CidrIp "0.0.0.0/0"
  }

  EC2_SecurityGroupEgress("ElbAnyAll") {
    GroupId Ref("ExternalKibanaElbSg")
    IpProtocol "-1"
    FromPort 0
    ToPort 65535
    CidrIp "0.0.0.0/0"
  }

  EC2_SecurityGroupEgress("LinuxKibanaAnyAll") {
    GroupId Ref("LinuxKibanaSg")
    IpProtocol "-1"
    FromPort 0
    ToPort 65535
    CidrIp "0.0.0.0/0"
  }

  ElasticLoadBalancing_LoadBalancer("ExternalElb") {
    Subnets([ Ref("PubSubnetAz1"), Ref("PubSubnetAz2") ])
    SecurityGroups([ Ref("ExternalKibanaElbSg") ])
    CrossZone(true)
    ConnectionDrainingPolicy({
      "Enabled" => true,
      "Timeout" => 300
    })
    Listeners([ {
      "LoadBalancerPort" => "80",
      "InstancePort" => "80",
      "Protocol" => "HTTP"
    } ])
    HealthCheck({
      "Target" => FnJoin("", [ "HTTP", ":", Ref("HealthCheckPort"), Ref("HealthCheckUri") ]),
      "HealthyThreshold" => 7,
      "UnhealthyThreshold" => 7,
      "Interval" => 6,
      "Timeout" => 5
    })
  }

  AutoScaling_LaunchConfiguration("LaunchConfig") {
    DependsOn ["InstanceProfile"]
    SecurityGroups [ Ref("LinuxKibanaSg") ]
    ImageId FnFindInMap('AWSEC2RegionArch2AMI',Ref('AWS::Region'),
        FnFindInMap('AWSEC2InstanceType2Arch',Ref("EC2InstanceType"),'Arch'))
    BlockDeviceMappings [ { :DeviceName => "/dev/xvda", :Ebs => { :VolumeSize => Ref("PrimaryVolumeSize"), :VolumeType => "gp2", :DeleteOnTermination => "true" }} ]
    Metadata('AWS::CloudFormation::Init', {
      :configSets => {
        :default => [ "installNginx", "installKibana", "installEsHq", "configureNginx", "dnsOverride", "runNginxAsService" ]
      },
      :installNginx => {
        :sources => {
          "/usr/share" => FnJoin("",["https://download.elasticsearch.org/kibana/kibana/kibana-",Ref("KibanaVersion"),".zip"])
        },
        :packages => {
            :yum => {
              "nginx" => [],
              "httpd-tools" => []
            }
        }
      },
      :installKibana => {
        :sources => {
          "/usr/share" => FnJoin("",["https://download.elasticsearch.org/kibana/kibana/kibana-",Ref("KibanaVersion"),".zip"])
        },
        :commands => {
          "1-renameKibana" => {
            "command" => FnJoin("",["cd /usr/share && mv kibana-",Ref("KibanaVersion")," kibana3"])
          },
          "2-configureKibana" => {
            "command" => FnJoin("",["cd /usr/share/kibana3 && sed -i -e 's/\\\+\\\"\\\:9200\\\"/\\\+\\\"\\\:80\\\"/g' config.js"])
          }
        }
      },
      :installEsHq => {
        :sources => {
          "/usr/share/kibana3/hq" => FnJoin("",["https://github.com/royrusso/elasticsearch-HQ/zipball/master"])
        }
      },
      :configureNginx => {
        :commands => {
          "1-downloadConfig" => {
            "command" => FnJoin("",["cd /etc/nginx/conf.d && wget https://raw.githubusercontent.com/elasticsearch/kibana/kibana3/sample/nginx.conf"])
          },
          "2-renameConfig" => {
            "command" => FnJoin("",["cd /etc/nginx/conf.d && mv nginx.conf kibana.conf"])
          },
          "3-updateEsHostname" => {
            "command" => FnJoin("",["sed -i -e 's/127\\\.0\\\.0\\\.1/",Ref("EsHostname"),"/g' /etc/nginx/conf.d/kibana.conf"])
          },
          "4-updateKibanaHostname" => {
            "command" => FnJoin("",["sed -i -e 's/kibana\\\.myhost\\\.org/",Ref("KibanaHostname"),"/g' /etc/nginx/conf.d/kibana.conf"])
          },
          "5-createAuthFile" => {
            "command" => FnJoin("",["htpasswd -b -c /etc/nginx/conf.d/",Ref("KibanaHostname"),".htpasswd ",Ref("KibanaDashboardUser")," ",Ref("KibanaDashboardPassword")])
          }
        }
      },
      :dnsOverride => {
        :commands => {
          :overrideDns => {
            "command" => FnJoin("",[
                "DnsResolverOverride=\"",Ref("DnsResolverOverride"),"\"\n",
                "if [[ -n ${DnsResolverOverride} ]]; then\n",
                " sed -i 's/^PEERDNS.*/PEERDNS\=no/g' /etc/sysconfig/network-scripts/ifcfg-eth0\n",
                " sed -i '/^nameserver/ d' /etc/resolv.conf\n",
                "\n",
                "DnsResolverList=$(echo ${DnsResolverOverride} | sed s/,/\\\n/g)\n",
                "for resolver in $(echo ${DnsResolverList}); do\n",
                " echo \"nameserver $resolver\" >> /etc/resolv.conf\n",
                "done\n",
                "fi\n"
              ])
          }
        }
      },
      :runNginxAsService => {
        :commands => {
          "1-chkLsService" => {
            "command" => FnJoin("",["/sbin/chkconfig --level 2345 nginx on"])
          },
          "2-startLsService" => {
            "command" => FnJoin("",["/etc/init.d/nginx start"])
          }
        }
      }
    })
    UserData FnBase64(
      FnJoin('', [
        "#!/bin/bash -v \n",

        "yum update -y\n",

        "# Helper function\n",
        "function error_exit\n",
        "{\n",
        "  /opt/aws/bin/cfn-signal -e 1 -r \"$1\" '", Ref("WaitHandle"), "'\n",
        "  exit 1\n",
        "}\n",

        "# CloudFormation init start\n",
        "/opt/aws/bin/cfn-init -v -c default -s ",Ref("AWS::StackId")," -r LaunchConfig --region ",Ref("AWS::Region"),"\n",

        "# Determine if nginx installed successfully\n",
        "if [[ ! -e /usr/sbin/nginx ]]; then\n",
        "  error_exit \"nginx failed to install successfully\"\n",
        "fi\n",

        "# Determine if the kibana configuration was successful\n",
        "$(grep -q ",Ref("EsHostname"), " /etc/nginx/conf.d/kibana.conf)\n",
        "if [[ $? != 0 ]]; then\n",
        "        error_exit \"kibana configuration failed\"\n",
        "fi\n",

        "# Determine if nginx started successfully\n",
        "$(ps cax |grep -q nginx)\n",
        "if [[ $? != 0 ]]; then\n",
        "        error_exit \"nginx failed to start\"\n",
        "fi\n",

        "## CloudFormation signal that setup is complete\n",
        "/opt/aws/bin/cfn-signal -e 0 -r \"Kibana setup complete\" '", Ref("WaitHandle") ,"'\n"
      ])
    )  
    KeyName Ref("KeyName")  
    InstanceType Ref("EC2InstanceType")
    IamInstanceProfile Ref("InstanceProfile")   
  }

  AutoScaling_AutoScalingGroup("AutoScalingGroup") {
    DependsOn ["LaunchConfig"]
    VPCZoneIdentifier [ Ref("SubnetAz1"), Ref("SubnetAz2") ]
    Tags [
      { :Key => "Owner", :Value => Ref("Owner"), :PropagateAtLaunch => true },
      { :Key => "Project", :Value => Ref("Project"), :PropagateAtLaunch => true },
      { :Key => "Environment Name", :Value => Ref("EnvironmentName"), :PropagateAtLaunch => true },
      { :Key => "Name", :Value => Ref("EnvironmentName"), :PropagateAtLaunch => true },
      { :Key => "StackType", :Value => Ref("StackType"), :PropagateAtLaunch => true }
    ]
    AvailabilityZones FnGetAZs("")
    LaunchConfigurationName Ref("LaunchConfig")
    LoadBalancerNames [Ref("ExternalElb")]
    MinSize Ref("MinInstances")
    MaxSize Ref("MaxInstances")
    DesiredCapacity Ref("MinInstances")
    HealthCheckType "ELB"
    HealthCheckGracePeriod 1200
  }

  AutoScaling_ScalingPolicy( "EsScaleUpPolicy" ) {
    DependsOn "AutoScalingGroup"
    AdjustmentType "ChangeInCapacity"
    AutoScalingGroupName Ref( "AutoScalingGroup")
    Cooldown 60
    ScalingAdjustment 2
  }

  AutoScaling_ScalingPolicy( "EsScaleDownPolicy" ) {
    DependsOn "AutoScalingGroup"
    AdjustmentType "ChangeInCapacity"
    AutoScalingGroupName Ref( "AutoScalingGroup")
    Cooldown 60
    ScalingAdjustment -2
  }

  CloudWatch_Alarm("EsCPUAlarmHigh") {
    DependsOn [ "EsScaleUpPolicy" ]
    AlarmDescription "Scale-up if CPU > 65% for 5 minutes"
    Threshold 65
    AlarmActions [ Ref("EsScaleUpPolicy" ) ]
    ComparisonOperator "GreaterThanThreshold"
    EvaluationPeriods 5
    MetricName "CPUUtilization"
    Namespace "AWS/EC2"
    Statistic "Average"
    Period 60     
    Dimensions [{
        "Name" => "AutoScalingGroupName",
        "Value" => Ref("AutoScalingGroup" )
    }]
  }

  CloudWatch_Alarm("EsCPUAlarmLow") {
    DependsOn [ "EsScaleDownPolicy" ]
    AlarmDescription "Scale-down if CPU < 35% for 20 minutes"
    Threshold 35
    AlarmActions [ Ref("EsScaleDownPolicy" ) ]
    ComparisonOperator "LessThanThreshold"
    EvaluationPeriods 20
    MetricName "CPUUtilization"
    Namespace "AWS/EC2"
    Statistic "Average"
    Period 60     
    Dimensions [{
        "Name" => "AutoScalingGroupName",
        "Value" => Ref("AutoScalingGroup" )
    }]
  }

  Output( "LinuxKibanaSg" ) {
      Description "Linux Kibana Security Group"
      Value Ref( "LinuxKibanaSg" )
  }

  Output( "ExternalKibanaElbSg" ) {
      Description "External Kibana Elastic Load Balancer Security Group"
      Value Ref( "ExternalKibanaElbSg" )
  }

  Output("LoadBalancerHostname") {
    Description "Load Balancer Hostname"
    Value FnGetAtt("ExternalElb", "DNSName")
  }

  Output("LoadBalancer") {
    Description "Load Balancer"
    Value Ref("ExternalElb")
  }
}