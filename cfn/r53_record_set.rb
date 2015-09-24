CloudFormation {
  
  Description "Stack Route53 Record Set"

  Parameter("EnvironmentName") {
    Description 'Name applied to all resources within the stack'
    ConstraintDescription 'must be a valid environment name'
    Type "String"
    Default "R53 Record Set"
  }

  Parameter("StackType") {
    Description 'Stack type'
    ConstraintDescription 'must be a valid stack type'
    Type "String"
    Default "R53 Record Set"
  }

  Parameter("Owner") {
    Description 'Stack owner'
    ConstraintDescription 'must be a valid email address'
    Type "String"
  }

  Parameter("HostedZoneName") {
    Description 'Service hosted zone name'
    ConstraintDescription 'must be a valid hostname'
    Type "String"
  }

  Parameter("RecordSetName") {
    Description 'Record Set Name'
    ConstraintDescription 'must be a valid Record Set Name'
    Type "String"
  }

  Parameter("RecordSetType") {
    Description 'Target stacks resource record type'
    ConstraintDescription 'must be a valid type'
    Type "String"
  }

  Parameter("ResourceRecordValue") {
    Description 'Resource record value'
    ConstraintDescription 'must be a valid resource record value'
    Type "String"
  }

  Parameter("RecordSetTtl") {
    Description 'Resource record TTL'
    ConstraintDescription 'must be a valid number'
    Type "Number"
    Default 60
  }

  Route53_RecordSet("RecordSet") {
    HostedZoneName FnJoin("",[ Ref("HostedZoneName"), "." ])
    Name FnJoin(".",[ Ref("RecordSetName"), Ref("HostedZoneName") ])
    Type Ref("RecordSetType")
    TTL Ref("RecordSetTtl")
    ResourceRecords [ Ref("ResourceRecordValue") ]
  }

  Output( "RecordSet") {
      Description "Record Set"
      Value Ref("RecordSet")
  }
}