# PROBLEM: Must manually keep network_cidr in sync with network module
app_name = "demo-app"
replicas = 3
network_cidr = "10.1.0.0/16"  # Duplicated from network module!
