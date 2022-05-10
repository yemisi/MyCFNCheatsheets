#In general its safer to put yaml strings in quotes but it is not required.
#The template version is with regards to AWS templates and not specific to json or yaml version.
AWSTemplateFormatVersion: "2010-09-09"        #The value for the template format version declaration must be a literal string
Description: >                                #The value for the description declaration must be a literal string that is between 0 and 1024 bytes in length  
  Here are some
  details about
  the template.

#Pseudo parameters are parameters that are predefined by AWS CloudFormation. You don't declare them in your template. Use them the same way as you would a parameter, as the argument for the Ref function
#E.g AWS::AccountId,AWS::NoValue,AWS::Region,AWS::StackName
#In the example below, If the UseDBSnapshot condition evaluates to true, CloudFormation uses the DBSnapshotName parameter value for the DBSnapshotIdentifier property. If the condition evaluates to false, CloudFormation removes the DBSnapshotIdentifier property.
# MyDB:
#   Type: AWS::RDS::DBInstance
#   Properties:
#     AllocatedStorage: '5'
#     DBInstanceClass: db.t2.small
#     Engine: MySQL
#     EngineVersion: '5.5'
#     MasterUsername:
#       Ref: DBUser
#     MasterUserPassword:
#       Ref: DBPassword
#     DBParameterGroupName:
#       Ref: MyRDSParamGroup
#     DBSnapshotIdentifier:
#       Fn::If:
#       - UseDBSnapshot
#       - Ref: DBSnapshotName
#       - Ref: AWS::NoValue

#Parameters must be declared and referenced from within the same template. You can reference parameters from the Resources and Outputs sections of the template.
#You can have a maximum of 200 parameters in an AWS CloudFormation template.
#Each parameter must be assigned a value at runtime for AWS CloudFormation to successfully provision the stack
#Paramters can be grouped into sections in the console using AWS::CloudFormation::Interface metadata key. See doc https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-cloudformation-interface.html 
Parameters:                             #Only Type and LogicalID are required
  InstanceTypeParameter:                #Required. Logical ID is required and must be alphanumeric
    Type: String                        #Required. Only AWS supported types are allowed. E.g String, Number etc. See below
    Description: Enter t2.micro, m1.small, or m1.large. Default is t2.micro.        #Optional. string of up to 4000 characters that describes the parameter.
    Default: t2.micro                   #Optional
    AllowedValues:                      #Optional. Different parameter properties are available based on the Type used. E.g MinLength,MaxLength etc(for String Types), MaxValue,MinValue etc(for Number Types)
      - t2.micro
      - m1.small
      - m1.large
  DbSubnetIpBlocks: 
    Description: "Comma-delimited list of three CIDR blocks"
    Type: CommaDelimitedList
    Default: "10.0.48.0/24, 10.0.112.0/24, 10.0.176.0/24"
    
    
#Other parameter properties include AllowedPattern,AllowedValues,ConstraintDescription,Default. See doc https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html
#Supported Types 
#String     .User can input "MyUserName"
#Number     .Integer or float.You can input 8888. It is validated as a number but When you use the parameter elsewhere in your template, the parameter value becomes a string
#List<Number> .An array of integers or floats that are separated by commas. E.g You can input "80,20" and a Ref would result in ["80","20"].. when you use the parameter elsewhere in your template (for example, by using the Ref intrinsic function), the parameter value becomes a list of strings.
#CommaDelimitedList   .An array of literal strings that are separated by commas. You can imput "test,dev,prod", and a Ref would result in ["test","dev","prod"].
#AWS-Specific Parameter Types #You must enter existing AWS values that are in your AWS account or region in which the stack is being created. Check doc for supported types https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html#aws-specific-parameter-types 
#SSM Parameter Types    specify a Systems Manager parameter key as the value of the SSM parameter, and AWS CloudFormation fetches the latest value from Parameter Store
#Resources are the only required section of the template


Resources:
  MyEC2Instance:                            #logical ID(Required) must be alphanumeric (A-Za-z0-9). The logical Id can be used to associate 2 resources together
    Type: "AWS::EC2::Instance"              #Required. Check AWS resource and property types reference doc: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html
    Properties:                             #Could be optional. If a resource doesn't require that properties be declared, you can also omit the properties section of that resource. 
      ImageId: "ami-0ff8a91507f77f867"
# This is how to declare different property value type. Property values can be literal strings, lists of strings, Booleans, parameter references, pseudo references, or the value returned by a function
# Properties:
#   String: OneStringValue
#   String: A longer string value 
#   Number: 123
#   LiteralList:
#     - "[first]-string-value with a special characters"
#     - "[second]-string-value with a special characters"
#   Boolean: true
#   ReferenceForOneValue:
#     Ref: MyLogicalResourceName
#   ReferenceForOneValueShortCut: !Ref MyLogicalResourceName
#   FunctionResultWithFunctionParams: !Sub |
#     Key=%${MyParameter}
  MyInstance: 
    Type: "AWS::EC2::Instance"
    Properties: 
      UserData: 
        "Fn::Base64":
          !Sub |
            Queue=${MyQueue}
      AvailabilityZone: "us-east-1a"
      ImageId: "ami-0ff8a91507f77f867"
  MyQueue: 
    Type: "AWS::SQS::Queue"
    Properties: {}                                  #This is how you create an empty property section.

#Outputs section declares output values that you can import into other stacks (to create cross-stack references), return in response (to describe stack calls), or view on the AWS CloudFormation console. It has a maximum of 200 outputs per template
Outputs:
  StackVPC:                                       #Logical ID is required & must be alphanumeric
    Description: The ID of the VPC                #Optional. The value must be a string literal with maz of 1024bytes
    Value: !Ref MyVPC                             #Required. The value of an output can include literals, parameter references, pseudo-parameters, a mapping value, or intrinsic functions.
    Export:                                       #The name of the resource output to be exported for a cross-stack reference. Check doc for limitations: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/outputs-section-structure.html
      Name: !Sub "${AWS::StackName}-VPCID"
#     Name: !Join [ ":", [ !Ref "AWS::StackName", AccountVPC ] ]      #Shows sample using Intrinsic fns to create the name