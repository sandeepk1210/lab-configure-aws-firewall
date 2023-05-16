#For Network firewall - Firewall is created last, once firewall policy and rules are created
resource "aws_networkfirewall_firewall" "networkFirewallLab" {
  name                = "networkFirewallLab"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.networkFirewallLab-policy.arn
  vpc_id              = aws_vpc.lab-vpc.id
  subnet_mapping {
    subnet_id = aws_subnet.firewall-subnet-public-1.id
  }

  delete_protection = true

  tags = {
    "Name" = "networkFirewallLab"
  }
}

#For Network firewall - Firewall policy is created 2nd, once rules are defined!
resource "aws_networkfirewall_firewall_policy" "networkFirewallLab-policy" {
  name = "networkFirewallLab-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:pass"]
    stateless_fragment_default_actions = ["aws:drop"]
    stateless_rule_group_reference {
      priority     = 1
      resource_arn = aws_networkfirewall_rule_group.statelessRules.arn
    }
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.statefulRules.arn
    }
  }

  tags = {
    "Name" = "networkFirewallLab-policy"
  }
}

#For Network firewall - Network rule group is to be setup 1st
resource "aws_networkfirewall_rule_group" "statefulRules" {
  capacity = 10
  name     = "statefulRules"
  type     = "STATEFUL"
  rule_group {
    rules_source {
      rules_source_list {
        generated_rules_type = "DENYLIST"
        target_types         = ["HTTP_HOST", "TLS_SNI"]
        targets              = ["test.example.com", "www.facebook.com"]
      }
    }
  }

  tags = {
    "Name" = "statefulRules"
  }
}

resource "aws_networkfirewall_rule_group" "statelessRules" {
  capacity = 10
  name     = "statelessRules"
  type     = "STATELESS"
  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 1
          rule_definition {
            actions = ["aws:pass"]
            match_attributes {
              source {
                address_definition = "10.0.0.0/16"
              }
              destination {
                address_definition = "10.0.0.0/16"
              }
            }
          }
        }
        stateless_rule {
          priority = 2
          rule_definition {
            actions = ["aws:drop"]
            match_attributes {
              source {
                address_definition = "192.0.2.0/24"
              }
            #   source_port {
            #     from_port = 443
            #     to_port   = 443
            #   }
              destination {
                address_definition = "0.0.0.0/0"
              }
            #   destination_port {
            #     from_port = 443
            #     to_port   = 443
            #   }
            #   protocols = [6]
            }
          }
        }
      }
    }
  }

  tags = {
    "Name" = "statelessRules"
  }
}