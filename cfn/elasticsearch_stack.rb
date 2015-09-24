CloudFormation {
  
  Description "Linux Elasticsearch Stack"

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
    Default "Elasticsearch Cluster"
  }

  Parameter("EsRepositoryBucket") {
    Description 'Repository bucket'
    ConstraintDescription 'must be a valid S3 bucket name'
    Type "String"
  }

  Parameter("EsVersion") {
    Description 'Elasticsearch Version'
    ConstraintDescription 'must be a valid Elasticsearch version'
    Type "String"
    Default "1.3.2"
  }

  Parameter("EsCloudAwsVersion") {
    Description 'Elasticsearch Cloud AWS plugin Version'
    ConstraintDescription 'must be a valid Elasticsearch Cloud AWS plugin version'
    Type "String"
    Default "2.3.0"
  }

  Parameter("EsClusterName") {
    Description 'Elasticsearch cluster name'
    ConstraintDescription 'must be a valid Elasticsearch cluster name'
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

  Parameter("HealthCheckUri"){
    Description 'Elb Health Check Uri'
    Type "String"
    Default "/_cluster/health"
    ConstraintDescription "must be a valid URI"
  }

  Parameter("HealthCheckPort"){
    Description 'Elb Health Check Port'
    Type "Number"
    Default 9200
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
    Policies [
      {
        :PolicyName => 'S3EsRepositoryBucketAccess',
        :PolicyDocument => {
          :Statement => [
            {
              :Effect => 'Allow',
              :Action => [
                "s3:ListBucket"
                ],
              :Resource =>  [ 
                FnJoin('',[ 'arn:aws:s3:::', Ref("EsRepositoryBucket")])
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
                FnJoin('',[ 'arn:aws:s3:::', Ref("EsRepositoryBucket"), '/*'])
              ]
            },
          ]
        }
      },
      {
        :PolicyName => 'EC2DescribeInstancesAccess',
        :PolicyDocument => {
          :Statement => [
            {
              :Effect => 'Allow',
              :Action => [
                'ec2:DescribeInstances'
                ],
              :Resource =>  '*'
            }
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

  EC2_SecurityGroup("LinuxEsSg") {
    GroupDescription "Elasticsearch Instances Security Group"
    VpcId Ref("VpcId")
  }

  EC2_SecurityGroup("InternalEsElbSg") {
    GroupDescription "Internal Elasticsearch Elastic Load Balancer Security Group"
    VpcId Ref("VpcId")
  }

  EC2_SecurityGroupIngress("InternalElbAnyEs") {
    GroupId Ref("InternalEsElbSg")
    IpProtocol "tcp"
    FromPort 9200
    ToPort 9299
    CidrIp "0.0.0.0/0"
  }

  EC2_SecurityGroupIngress("InternalElbLinuxEs") {
    GroupId Ref("LinuxEsSg")
    IpProtocol "tcp"
    FromPort 9200
    ToPort 9299
    SourceSecurityGroupId Ref("InternalEsElbSg")
  }

  EC2_SecurityGroupIngress("LinuxEsAnySsh") {
    GroupId Ref("LinuxEsSg")
    IpProtocol "tcp"
    FromPort 22
    ToPort 22
    CidrIp "0.0.0.0/0"
  }
  
  EC2_SecurityGroupIngress("LinuxEsAnyEs") {
    GroupId Ref("LinuxEsSg")
    IpProtocol "tcp"
    FromPort 9200
    ToPort 9299
    CidrIp "0.0.0.0/0"
  }

  EC2_SecurityGroupIngress("LinuxEsEsTransport") {
    GroupId Ref("LinuxEsSg")
    IpProtocol "tcp"
    FromPort 9300
    ToPort 9300
    SourceSecurityGroupId Ref("LinuxEsSg")
  }

  EC2_SecurityGroupEgress("ElbAnyAll") {
    GroupId Ref("InternalEsElbSg")
    IpProtocol "-1"
    FromPort 0
    ToPort 65535
    CidrIp "0.0.0.0/0"
  }

  EC2_SecurityGroupEgress("LinuxEsAnyAll") {
    GroupId Ref("LinuxEsSg")
    IpProtocol "-1"
    FromPort 0
    ToPort 65535
    CidrIp "0.0.0.0/0"
  }

  ElasticLoadBalancing_LoadBalancer("InternalElb") {
    Subnets([ Ref("SubnetAz1"), Ref("SubnetAz2") ])
    SecurityGroups([ Ref("InternalEsElbSg") ])
    CrossZone(true)
    Scheme("internal")
    ConnectionDrainingPolicy({
      "Enabled" => true,
      "Timeout" => 300
    })
    Listeners([ {
      "LoadBalancerPort" => "9200",
      "InstancePort" => "9200",
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
    SecurityGroups [ Ref("LinuxEsSg") ]
    ImageId FnFindInMap('AWSEC2RegionArch2AMI',Ref('AWS::Region'),
        FnFindInMap('AWSEC2InstanceType2Arch',Ref("EC2InstanceType"),'Arch'))
    BlockDeviceMappings [ { :DeviceName => "/dev/xvda", :Ebs => { :VolumeSize => Ref("PrimaryVolumeSize"), :VolumeType => "gp2", :DeleteOnTermination => "true" }} ]
    Metadata('AWS::CloudFormation::Init', {
      :configSets => {
        :default => [ "download", "fixPermissions", "installPlugins", "createEsConfig", "dnsOverride", "runEsAsService" ]
      },
      :download => {
        :sources => {
          "/usr/local/elasticsearch" => FnJoin("",["https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-",Ref("EsVersion"),".zip"])
        },
        :commands => {
          :createSymlink => {
            "command" => FnJoin("",["cd /usr/local/elasticsearch && ln -s elasticsearch-",Ref("EsVersion")," elasticsearch"])
          }
        }
      },
      :fixPermissions => {
        :commands => {
          :fixEsPermssions => {
            "command" => FnJoin("",["chmod +x /usr/local/elasticsearch/elasticsearch-",Ref("EsVersion"),"/bin/*"])
          }
        }
      },
      :installPlugins => {
        :commands => {
          :installEsCloudAws => {
            "command" => FnJoin("",["cd /usr/local/elasticsearch/elasticsearch-",Ref("EsVersion")," && bin/plugin -install elasticsearch/elasticsearch-cloud-aws/",Ref("EsCloudAwsVersion")])
          }
        }
      },
      :createEsConfig => {
        :files => {
          "/usr/local/elasticsearch/elasticsearch/config/elasticsearch.yml" => {
            "content" => FnJoin("",[
              "cluster:\n",
              " name: ",Ref("EsClusterName"),"\n",
              "\n",
              "discovery:\n",
              "  type: ec2\n",
              "\n",
              "  ec2:\n",
              "   groups: ",Ref("LinuxEsSg"),"\n",
              "\n",
              "cloud:\n",
              " aws:\n",
              "  region: ",Ref("AWS::Region"),"\n",
              "\n",
              "discovery.zen.ping.multicast.enabled: false\n",
            ])
          }
        }
      },
      :runEsDaemon => {
        :commands => {
          :runEs => {
            "command" => FnJoin("",["cd /usr/local/elasticsearch/elasticsearch-",Ref("EsVersion")," && bin/elasticsearch -d"])
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
      :runEsAsService => {
        :sources => {
          "/usr/local/elasticsearch" => FnJoin("",["https://github.com/elasticsearch/elasticsearch-servicewrapper/zipball/master"])
          },
        :commands => {
          "1-moveWrapper" => {
            "command" => FnJoin("",["cd /usr/local/elasticsearch && mv service /usr/local/elasticsearch/elasticsearch-",Ref("EsVersion"),"/bin"])
          },
          "2-fixEsPermssions" => {
            "command" => FnJoin("",["chmod +x -R /usr/local/elasticsearch/elasticsearch-",Ref("EsVersion"),"/bin/service/*"])
          },
          "3-updateEsServiceConfig" => {
            "command" => FnJoin("",["sed -e 's/<Path to Elasticsearch Home>/\\\/usr\\\/local\\\/elasticsearch-",Ref("EsVersion"),"\\\/elasticsearch/g' /usr/local/elasticsearch/elasticsearch-",Ref("EsVersion"),"/bin/service/elasticsearch.conf -i"])
          },
          "4-installEsService" => {
            "command" => FnJoin("",["/usr/local/elasticsearch/elasticsearch-",Ref("EsVersion"),"/bin/service/elasticsearch64 install"])
          },
          "5-startEsService" => {
            "command" => FnJoin("",["/usr/local/elasticsearch/elasticsearch-",Ref("EsVersion"),"/bin/service/elasticsearch64 start"])
          },
          "6-chkEsService" => {
            "command" => FnJoin("",["/sbin/chkconfig --level 2345 elasticsearch on"])
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

        "# Determine if es installed successfully\n",
        "if [[ ! -e /usr/local/elasticsearch/elasticsearch/bin/elasticsearch ]]; then\n",
        "  error_exit \"elasticsearch failed to install successfully\"\n",
        "fi\n",

        "# Determine if the es configuration was successful\n",
        "$(grep -q ",Ref("EsClusterName"), " /usr/local/elasticsearch/elasticsearch/config/elasticsearch.yml)\n",
        "if [[ $? != 0 ]]; then\n",
        "        error_exit \"elasticsearch configuration failed\"\n",
        "fi\n",

        "# Determine if es started successfully\n",
        "$(ps cax |grep -q elasticsearch-l)\n",
        "if [[ $? != 0 ]]; then\n",
        "        error_exit \"elasticsearch failed to start\"\n",
        "fi\n",

        "## CloudFormation signal that setup is complete\n",
        "/opt/aws/bin/cfn-signal -e 0 -r \"Elasticsearch setup complete\" '", Ref("WaitHandle") ,"'\n"
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

  Output( "LinuxEsSg" ) {
      Description "Linux Elasticsearch Security Group"
      Value Ref( "LinuxEsSg" )
  }

  Output( "InternalEsElbSg" ) {
      Description "Internal Elasticsearch Elastic Load Balancer Security Group"
      Value Ref( "InternalEsElbSg" )
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