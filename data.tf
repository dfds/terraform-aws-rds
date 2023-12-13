data "aws_rds_engine_version" "engine_info" { # preferred vesion.
  engine       = local.engine
  version      = var.engine_version
  default_only = !local.is_major_engine_version || var.engine_version == null
}



dfds_owner:  Identifies the owner of the resource	Required	Global (exc. AWS capabilities[3])	All	Should contain a contact email
dfds_env	Indicates the environment [dev, test, staging, uat, training, prod]	Required	Global	All	Helps manage resources in different environments
dfds_cost_centre	Identifies the cost center for resource allocation,	Required	Global	All	Format <BU-subunit>, e.g. ti-ferry
dfds_data_backup	Indicates whether this datastore should be included in a durable backup scheme [true, false]	Required for prod instances	Backup	Storage, Databases
dfds_data_backup_retention	Indicates the desired longevity of backups	Required for prod instances	Backup	Storage, Databases	Must be a known value, see next section
dfds_data_classification	Classifies data sensitivity [public, private, confidential, restricted]	Required for classification <> public	Data	Storage, Databases	Use when applicable.
dfds_service_availability	Indicates the mission criticality of the service [low, medium, high]	Required for prod instances	Global	All

Not all resources need same tags, like RDS needs dfds.data.backup
while the parameter group does not need
