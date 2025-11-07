# PROBLEM: Must manually keep network_cidr in sync with network module
app_name = "demo-app"
replicas = 2
network_cidr = "10.0.1.0/16"  # Duplicated from network module!
