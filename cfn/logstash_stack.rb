CloudFormation {
  
  Description "Linux Logstash Stack"

  Parameter("KeyName") {
    Description 'Name of an existing EC2 KeyPair to enable SSH access to the instances'
    Type "String"
  }

  Parameter("EnvironmentName") {
    Description 'Name applied to all resources within the stack'
    ConstraintDescription 'must be a valid environment name'
    Type "String"
    Default "Micro Service 1"
  }

  Parameter("StackType") {
    Description 'Stack type'
    ConstraintDescription 'must be a valid stack type'
    Type "String"
    Default "lsa"
  }

  Parameter("LsVersion") {
    Description 'Logstash Version - only used when installing using the source based configSets'
    ConstraintDescription 'must be a valid logstash version'
    Type "String"
    Default "1.4.2"
  }

  Parameter("EsHostname") {
    Description 'Elasticsearch Hostname'
    ConstraintDescription 'must be a valid hostname'
    Type "String"
  }

  Parameter("ResourceBucket") {
    Description 'Resource bucket'
    ConstraintDescription 'must be a valid S3 bucket name'
    Type "String"
  }

  Parameter("ArchiveUri") {
    Description 'Stack Archive URI'
    ConstraintDescription 'must be a valid S3 bucket name'
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
    Description 'Subnet within AZ 1 to deploy instances'
    Type "String"
    AllowedPattern "subnet-[a-zA-Z0-9]{8}"
  }

  Parameter("SubnetAz2") {
    Description 'Subnet within AZ 2 to deploy instances'
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
    Description 'Minimum number of Es instances'
    Type "Number"
    Default 2
    MinValue 1
    MaxValue 4
    ConstraintDescription "must be between 1 and 4."
  }

  Parameter("MaxInstances") {
    Description 'Maximum number of Es instances'
    Type "Number"
    Default 2
    MinValue 1
    MaxValue 8
    ConstraintDescription "must be between 1 and 8."
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
    Policies [
      {
        :PolicyName => 'S3ResourceBucketAccess',
        :PolicyDocument => {
          :Statement => [
            {
              :Effect => 'Allow',
              :Action => [
                "s3:ListBucket"
                ],
              :Resource =>  [ 
                FnJoin('',[ 'arn:aws:s3:::', Ref("ResourceBucket")])
              ]
            },
            {
              :Effect => 'Allow',
              :Action => [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
              ],
              :Resource =>  [ 
                FnJoin('',[ 'arn:aws:s3:::', Ref("ResourceBucket"), '/*'])
              ]
            },
          ]
        }
      }
    ]
  }

  IAM_InstanceProfile("InstanceProfile") {
    Path '/'
    Roles [ Ref("InstanceRole") ]
    DependsOn("InstanceRole")
  }

  EC2_SecurityGroup("LinuxLsSg") {
    GroupDescription "Logstash Instances Security Group"
    VpcId Ref("VpcId")
  }

  EC2_SecurityGroup("InternalLsElbSg") {
    GroupDescription "Internal Logstash Elastic Load Balancer Security Group"
    VpcId Ref("VpcId")
  }

  EC2_SecurityGroupIngress("InternalElbAnyLs") {
    GroupId Ref("InternalLsElbSg")
    IpProtocol "tcp"
    FromPort 9299
    ToPort 9299
    CidrIp "0.0.0.0/0"
  }

  EC2_SecurityGroupIngress("InternalElbLinuxLs") {
    GroupId Ref("LinuxLsSg")
    IpProtocol "tcp"
    FromPort 9299
    ToPort 9299
    SourceSecurityGroupId Ref("InternalLsElbSg")
  }

  EC2_SecurityGroupIngress("LinuxLsAnySsh") {
    GroupId Ref("LinuxLsSg")
    IpProtocol "tcp"
    FromPort 22
    ToPort 22
    CidrIp "0.0.0.0/0"
  }
  
  EC2_SecurityGroupIngress("LinuxLsAnyLs") {
    GroupId Ref("LinuxLsSg")
    IpProtocol "tcp"
    FromPort 9299
    ToPort 9299
    CidrIp "0.0.0.0/0"
  }

  EC2_SecurityGroupEgress("ElbAnyAll") {
    GroupId Ref("InternalLsElbSg")
    IpProtocol "-1"
    FromPort 0
    ToPort 65535
    CidrIp "0.0.0.0/0"
  }

  EC2_SecurityGroupEgress("LinuxLsAnyAll") {
    GroupId Ref("LinuxLsSg")
    IpProtocol "-1"
    FromPort 0
    ToPort 65535
    CidrIp "0.0.0.0/0"
  }

  ElasticLoadBalancing_LoadBalancer("InternalElb") {
    Subnets([ Ref("SubnetAz1"), Ref("SubnetAz2") ])
    SecurityGroups([ Ref("InternalLsElbSg") ])
    CrossZone(true)
    Scheme("internal")
    ConnectionDrainingPolicy({
      "Enabled" => true,
      "Timeout" => 300
    })
    Listeners([ {
      "LoadBalancerPort" => "9299",
      "InstancePort" => "9299",
      "Protocol" => "TCP"
    } ])
    HealthCheck({
      "Target" => FnJoin("", [ "TCP", ":", "9299" ]),
      "HealthyThreshold" => 7,
      "UnhealthyThreshold" => 7,
      "Interval" => 6,
      "Timeout" => 5
    })
  }

  AutoScaling_LaunchConfiguration("LaunchConfig") {
    DependsOn ["InstanceProfile"]
    SecurityGroups [ Ref("LinuxLsSg") ]
    ImageId FnFindInMap('AWSEC2RegionArch2AMI',Ref('AWS::Region'),
        FnFindInMap('AWSEC2InstanceType2Arch',Ref("EC2InstanceType"),'Arch'))
    BlockDeviceMappings [ { :DeviceName => "/dev/xvda", :Ebs => { :VolumeSize => Ref("PrimaryVolumeSize"), :VolumeType => "gp2", :DeleteOnTermination => "true" }} ]
    Metadata('AWS::CloudFormation::Authentication',
      "s3access" => {
        :type => "s3",
        :buckets => [Ref("ResourceBucket")],
        :roleName => Ref("InstanceRole")
    })
    Metadata('AWS::CloudFormation::Init', {
      :configSets => {
        :default => [ "downloadLsSource", "setupLsFromSource", "installLsConfigs", "dnsOverride", "runLsAsService" ]
      },
      :configureLsRepo => {
        :files => {
          "/etc/yum.repos.d/logstash.repo" => {
            "content" => FnJoin("",[
              "[logstash-1.4]\n",
              "name=logstash repository for 1.4.x packages\n",
              "baseurl=http://packages.elasticsearch.org/logstash/1.4/centos\n",
              "gpgcheck=1\n",
              "gpgkey=http://packages.elasticsearch.org/GPG-KEY-elasticsearch\n",
              "enabled=1\n"
            ])
          }
        },
        :commands => {
          :createSymlink => {
            "command" => FnJoin("",["rpm --import http://packages.elasticsearch.org/GPG-KEY-elasticsearch"])
          }
        }
      },
      :installLsFromRepo => {
        :commands => {
          :yumInstallLs => {
            "command" => FnJoin("",["yum install logstash -y"])
          }
        }
      },
      :downloadLsSource => {
        :sources => {
          "/opt" => FnJoin("",["https://download.elasticsearch.org/logstash/logstash/logstash-",Ref("LsVersion"),".zip"])
        },
        :commands => {
          :createSymlink => {
            "command" => FnJoin("",["cd /opt && ln -s logstash-",Ref("LsVersion")," logstash"])
          },
          :fixLsPermssions => {
            "command" => FnJoin("",["chmod +x /opt/logstash-",Ref("LsVersion"),"/bin/*"])
          }
        }
      },
      :setupLsFromSource => {
        :files => {
          '/etc/init.d/logstash' => {
            "content" => FnJoin('', File.open('./scripts/logstash').readlines)
          }
        },
        :commands => {
          "1-createLsUser" => {
            "command" => FnJoin("",["useradd -s /sbin/nologin -M -d /opt/logstash logstash"])
          },
          "2-createLsVarDir" => {
            "command" => FnJoin("",["mkdir /var/lib/logstash && chown logstash:logstash /var/lib/logstash"])
          },
          "3-createLsLogDir" => {
            "command" => FnJoin("",["mkdir /var/log/logstash && chown logstash:logstash /var/log/logstash"])
          },
          "4-setupLsInit" => {
            "command" => FnJoin("",["chmod 755 /etc/init.d/logstash"])
          }
        }
      },
      :installLsConfigs => {
        :sources => {
          "/etc/logstash" => FnJoin("",["https://",Ref("ResourceBucket"),".s3.amazonaws.com","/",Ref("ArchiveUri"),"/source.zip"])
        },
        :commands => {
          "1-updateLsConfigs" => {
              "command" => FnJoin("",["sed -i -e 's/es\\\.myhost\\\.org/",Ref("EsHostname"),"/g' /etc/logstash/conf.d/*"])
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
      :runLsAsService => {
        :commands => {
          "1-chkLsService" => {
            "command" => FnJoin("",["/sbin/chkconfig --level 2345 logstash on"])
          },
          "2-startLsService" => {
            "command" => FnJoin("",["/etc/init.d/logstash start"])
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

        "# Determine if ls installed successfully\n",
        "if [[ ! -e /opt/logstash/bin/logstash ]]; then\n",
        "  error_exit \"logstash failed to install successfully\"\n",
        "fi\n",

        "# Determine if the ls configuration was successful\n",
        "$(grep -q ",Ref("EsHostname"), " /etc/logstash/conf.d/*)\n",
        "if [[ $? != 0 ]]; then\n",
        "        error_exit \"logstash configuration failed\"\n",
        "fi\n",

        "# Determine if ls started successfully\n",
        "let iterations=10\n",
        "for i in $(seq 0 ${iterations});\n",
        "do\n",
        "  $(ps ax |grep -q [l]ogstash\/runner\.rb)\n",
        "\n",  
        "  status=$?\n",
        "\n",
        "  if [[ ${status} != 0 ]] && [[ ${i} == ${iterations} ]]; then\n",
        "    error_exit \"logstash failed to start\"\n",
        "  elif [[ ${status} != 0 ]]; then\n",
        "    echo \"waiting for logstash to start\"\n",
        "  else\n", 
        "    continue\n",
        "  fi\n",
        "\n",
        "  sleep 5\n",
        "done\n",

        "## CloudFormation signal that setup is complete\n",
        "/opt/aws/bin/cfn-signal -e 0 -r \"Logstash setup complete\" '", Ref("WaitHandle") ,"'\n"
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
    LoadBalancerNames [Ref("InternalElb")]
    MinSize Ref("MinInstances")
    MaxSize Ref("MaxInstances")
    DesiredCapacity Ref("MinInstances")
    HealthCheckType "EC2"
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

  Output( "LinuxLsSg" ) {
      Description "Linux Logstash Security Group"
      Value Ref( "LinuxLsSg" )
  }

  Output( "InternalLsElbSg" ) {
      Description "Internal Logstash Elastic Load Balancer Security Group"
      Value Ref( "InternalLsElbSg" )
  }

  Output("LoadBalancerHostname") {
    Description "Load Balancer Hostname"
    Value FnGetAtt("InternalElb", "DNSName")
  }

  Output("LoadBalancer") {
    Description "Load Balancer"
    Value Ref("InternalElb")
  }
}