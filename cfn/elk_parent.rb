CloudFormation {
  
  Description "Linux ELK Parent Template"

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

  Parameter("NestedTemplateBaseUrl") {
    Description "Base URL to include nested templates from"
    Type "String"
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

  Parameter("HostedZoneName") {
    Description 'Service hosted zone name'
    ConstraintDescription 'must be a valid zonename'
    Type "String"
  }

  Parameter("InternalHostedZoneName") {
    Description 'Service internal hosted zone name'
    ConstraintDescription 'must be a valid zonename'
    Type "String"
  }

  Parameter("ResourceBucket") {
    Description 'Resource bucket'
    ConstraintDescription 'must be a valid S3 bucket name'
    Type "String"
  }

  Parameter("EsEC2InstanceType") {
    Description 'Elasticseach EC2 instance type'
    ConstraintDescription 'must be a valid EC2 instance type'
    Type "String"
    Default "t2.medium"
    AllowedValues ['t1.micro', 't2.micro', 't2.small', 't2.medium', 'm1.small', 'm1.medium',
                   'm1.large', 'm1.xlarge', 'm3.medium', 'm3.large', 'm3.xlarge', 'm3.2xlarge',
                   'c3.large', 'c3.xlarge', 'c3.2xlarge', 'c3.4xlarge', 'c3.8xlarge']
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

  Parameter("EsPrimaryVolumeSize"){
    Description 'Elasticsearch Primary Volume Size in Gb'
    Type "Number"
    MinValue 1
    MaxValue 1000
    Default 50
    ConstraintDescription "must be between 1 and 750."
  }

  Parameter("EsMinInstances") {
    Description 'Minimum number of Elasticsearch instances'
    Type "Number"
    Default 2
    MinValue 1
    MaxValue 4
    ConstraintDescription "must be between 1 and 4."
  }

  Parameter("EsMaxInstances") {
    Description 'Maximum number of Elasticsearch instances'
    Type "Number"
    Default 2
    MinValue 1
    MaxValue 8
    ConstraintDescription "must be between 1 and 8."
  }

  Parameter("EsHealthCheckUri"){
    Description 'Elb Health Check Uri'
    Type "String"
    Default "/_cluster/health"
    ConstraintDescription "must be a valid URI"
  }

  Parameter("EsHealthCheckPort"){
    Description 'Elb Health Check Port'
    Type "Number"
    Default 9200
    MinValue 1
    MaxValue 65535
    ConstraintDescription "must be between 1 and 65535."
  }

  Parameter("EsSubdomain") {
    Description 'Elasticsearch subdomain'
    ConstraintDescription 'must be a valid subdomain'
    Type "String"
    Default "es"
  }

  Parameter("LsEC2InstanceType") {
    Description 'Logstash EC2 instance type'
    ConstraintDescription 'must be a valid EC2 instance type'
    Type "String"
    Default "t2.medium"
    AllowedValues ['t1.micro', 't2.micro', 't2.small', 't2.medium', 'm1.small', 'm1.medium',
                   'm1.large', 'm1.xlarge', 'm3.medium', 'm3.large', 'm3.xlarge', 'm3.2xlarge',
                   'c3.large', 'c3.xlarge', 'c3.2xlarge', 'c3.4xlarge', 'c3.8xlarge']
  }

  Parameter("LsPrimaryVolumeSize"){
    Description 'Logstash Size in Gb'
    Type "Number"
    MinValue 1
    MaxValue 1000
    Default 50
    ConstraintDescription "must be between 1 and 750."
  }

  Parameter("LsMinInstances") {
    Description 'Minimum number of Logstash instances'
    Type "Number"
    Default 2
    MinValue 1
    MaxValue 4
    ConstraintDescription "must be between 1 and 4."
  }

  Parameter("LsMaxInstances") {
    Description 'Maximum number of Logstash instances'
    Type "Number"
    Default 2
    MinValue 1
    MaxValue 8
    ConstraintDescription "must be between 1 and 8."
  }

  Parameter("LsSubdomain") {
    Description 'Logstash subdomain'
    ConstraintDescription 'must be a valid subdomain'
    Type "String"
    Default "ls"
  }

  Parameter("LsArchiveUri") {
    Description 'Stack Archive URI'
    ConstraintDescription 'must be a valid S3 bucket name'
    Type "String"
  }

  Parameter("KibanaVersion") {
    Description 'Kibana Version'
    ConstraintDescription 'must be a valid Kibana version'
    Type "String"
    Default "3.1.0"
  }

  Parameter("KibanaEC2InstanceType") {
    Description 'Kibana EC2 instance type'
    ConstraintDescription 'must be a valid EC2 instance type'
    Type "String"
    Default "t2.medium"
    AllowedValues ['t1.micro', 't2.micro', 't2.small', 't2.medium', 'm1.small', 'm1.medium',
                   'm1.large', 'm1.xlarge', 'm3.medium', 'm3.large', 'm3.xlarge', 'm3.2xlarge',
                   'c3.large', 'c3.xlarge', 'c3.2xlarge', 'c3.4xlarge', 'c3.8xlarge']
  }

  Parameter("KibanaPrimaryVolumeSize"){
    Description 'Kibana Size in Gb'
    Type "Number"
    MinValue 1
    MaxValue 1000
    Default 50
    ConstraintDescription "must be between 1 and 750."
  }

  Parameter("KibanaMinInstances") {
    Description 'Minimum number of Kibana instances'
    Type "Number"
    Default 1
    MinValue 1
    MaxValue 4
    ConstraintDescription "must be between 1 and 4."
  }

  Parameter("KibanaMaxInstances") {
    Description 'Maximum number of Kibana instances'
    Type "Number"
    Default 1
    MinValue 1
    MaxValue 8
    ConstraintDescription "must be between 1 and 8."
  }

  Parameter("KibanaSubdomain") {
    Description 'Kibana subdomain'
    ConstraintDescription 'must be a valid subdomain'
    Type "String"
    Default "kibana"
  }

  Parameter("KibanaDashboardUser") {
    Description 'Kibana Dashboard User'
    ConstraintDescription 'must be a valid user'
    Type "String"
    Default "kibanadash"
  }

  Parameter("KibanaDashboardPassword") {
    Description 'Kibana Dashboard Password'
    Type "String"
    NoEcho "true"
    Default "Passw0rd1"
    AllowedPattern "[a-zA-Z0-9]*"
    ConstraintDescription "must contain only alphanumeric characters."
  }

  Parameter("KibanaHealthCheckUri"){
    Description 'Kibana Elb Health Check Uri'
    Type "String"
    Default "/"
    ConstraintDescription "must be a valid URI"
  }

  Parameter("KibanaHealthCheckPort"){
    Description 'Kibana Elb Health Check Port'
    Type "Number"
    Default 80
    MinValue 1
    MaxValue 65535
    ConstraintDescription "must be between 1 and 65535."
  }

  CloudFormation_Stack("EsStack") {
    TemplateURL FnJoin("", [ Ref("NestedTemplateBaseUrl"), "elasticsearch_stack.template" ])
    TimeoutInMinutes 300
    Parameters(
      {
        :KeyName => Ref("KeyName"),
        :EnvironmentName => FnJoin("-", [ Ref("EnvironmentName") , "Elasticsearch"] ),
        :StackType => "es",
        :EsRepositoryBucket => Ref("EsRepositoryBucket"),
        :EsVersion => Ref("EsVersion"),
        :EsCloudAwsVersion => Ref("EsCloudAwsVersion"),
        :EsClusterName => Ref("EsClusterName"),
        :EC2InstanceType => Ref("EsEC2InstanceType"),
        :VpcId => Ref("VpcId"),
        :SubnetAz1 => Ref("SubnetAz1"),
        :SubnetAz2 => Ref("SubnetAz2"),
        :DnsResolverOverride => Ref("DnsResolverOverride"),
        :PrimaryVolumeSize => Ref("EsPrimaryVolumeSize"),
        :MinInstances => Ref("EsMinInstances"),
        :MaxInstances => Ref("EsMaxInstances"),
        :HealthCheckUri => Ref("EsHealthCheckUri"),
        :HealthCheckPort => Ref("EsHealthCheckPort"),
        :Project => Ref("Project"),
        :Owner => Ref("Owner")
      }
    )
  }

  CloudFormation_Stack("EsR53Stack") {
    DependsOn [ "EsStack" ]
    TemplateURL FnJoin("", [ Ref("NestedTemplateBaseUrl"), "r53_record_set.template" ])
    TimeoutInMinutes 300
    Parameters(
      {
        :HostedZoneName => Ref("InternalHostedZoneName"),
        :RecordSetName => Ref("EsSubdomain"),
        :RecordSetType => "CNAME",
        :ResourceRecordValue => FnJoin("", [ FnGetAtt("EsStack", "Outputs.LoadBalancerHostname"), "." ] ),
        :Owner => Ref("Owner")
      }
    )
  }

  CloudFormation_Stack("LsStack") {
    DependsOn [ "EsStack" ]
    TemplateURL FnJoin("", [ Ref("NestedTemplateBaseUrl"), "logstash_stack.template" ])
    TimeoutInMinutes 300
    Parameters(
      {
        :KeyName => Ref("KeyName"),
        :EnvironmentName => FnJoin("-", [ Ref("EnvironmentName") , "Logstash"] ),
        :StackType => "lsa",
        :EsHostname => FnJoin(".", [ Ref("EsSubdomain"), Ref("InternalHostedZoneName") ]),
        :ResourceBucket => Ref("ResourceBucket"),
        :ArchiveUri => Ref("LsArchiveUri"),
        :EC2InstanceType => Ref("LsEC2InstanceType"),
        :VpcId => Ref("VpcId"),
        :SubnetAz1 => Ref("SubnetAz1"),
        :SubnetAz2 => Ref("SubnetAz2"),
        :DnsResolverOverride => Ref("DnsResolverOverride"),
        :PrimaryVolumeSize => Ref("LsPrimaryVolumeSize"),
        :MinInstances => Ref("LsMinInstances"),
        :MaxInstances => Ref("LsMaxInstances"),
        :Project => Ref("Project"),
        :Owner => Ref("Owner")
      }
    )
  }

  CloudFormation_Stack("LsR53Stack") {
    DependsOn [ "LsStack" ]
    TemplateURL FnJoin("", [ Ref("NestedTemplateBaseUrl"), "r53_record_set.template" ])
    TimeoutInMinutes 300
    Parameters(
      {
        :HostedZoneName => Ref("InternalHostedZoneName"),
        :RecordSetName => Ref("LsSubdomain"),
        :RecordSetType => "CNAME",
        :ResourceRecordValue => FnJoin("", [ FnGetAtt("LsStack", "Outputs.LoadBalancerHostname"), "." ] ),
        :Owner => Ref("Owner")
      }
    )
  }

  CloudFormation_Stack("KibanaStack") {
    DependsOn [ "LsStack" ]
    TemplateURL FnJoin("", [ Ref("NestedTemplateBaseUrl"), "kibana_stack.template" ])
    TimeoutInMinutes 300
    Parameters(
      {
        :KeyName => Ref("KeyName"),
        :EnvironmentName => FnJoin("-", [ Ref("EnvironmentName") , "Kibana"] ),
        :StackType => "kibana",
        :KibanaVersion => Ref("KibanaVersion"),
        :KibanaHostname => FnJoin(".", [ Ref("KibanaSubdomain"), Ref("HostedZoneName") ]),
        :KibanaDashboardUser => Ref("KibanaDashboardUser"),
        :KibanaDashboardPassword => Ref("KibanaDashboardPassword"),
        :EsHostname => FnJoin(".", [ Ref("EsSubdomain"), Ref("InternalHostedZoneName") ]),
        :EC2InstanceType => Ref("KibanaEC2InstanceType"),
        :VpcId => Ref("VpcId"),
        :SubnetAz1 => Ref("SubnetAz1"),
        :SubnetAz2 => Ref("SubnetAz2"),
        :PubSubnetAz1 => Ref("PubSubnetAz1"),
        :PubSubnetAz2 => Ref("PubSubnetAz2"),        
        :DnsResolverOverride => Ref("DnsResolverOverride"),
        :PrimaryVolumeSize => Ref("KibanaPrimaryVolumeSize"),
        :MinInstances => Ref("KibanaMinInstances"),
        :MaxInstances => Ref("KibanaMaxInstances"),
        :HealthCheckUri => Ref("KibanaHealthCheckUri"),
        :HealthCheckPort => Ref("KibanaHealthCheckPort"),
        :Project => Ref("Project"),
        :Owner => Ref("Owner")
      }
    )
  }

  CloudFormation_Stack("KibanaR53Stack") {
    DependsOn [ "KibanaStack" ]
    TemplateURL FnJoin("", [ Ref("NestedTemplateBaseUrl"), "r53_record_set.template" ])
    TimeoutInMinutes 300
    Parameters(
      {
        :HostedZoneName => Ref("HostedZoneName"),
        :RecordSetName => Ref("KibanaSubdomain"),
        :RecordSetType => "CNAME",
        :ResourceRecordValue => FnJoin("", [ FnGetAtt("KibanaStack", "Outputs.LoadBalancerHostname"), "." ] ),
        :Owner => Ref("Owner")
      }
    )
  }

  Output("EsEndpoint") {
    Description "Elasticsearch Endpoint"
    Value FnGetAtt("EsR53Stack", "Outputs.RecordSet")
  }

  Output("LsEndpoint") {
    Description "Logstash Endpoint"
    Value FnGetAtt("LsR53Stack", "Outputs.RecordSet")
  }

  Output("KibanaEndpoint") {
    Description "Kibana Endpoint"
    Value FnGetAtt("KibanaR53Stack", "Outputs.RecordSet")
  }
}