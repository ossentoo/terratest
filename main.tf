resource "azurerm_resource_group" "frontdoor-test" {
  name     = "frontdoor-test"
  location = "northeurope"

  tags = {
    environment = "Development"
  }
}

resource "azurerm_app_service_plan" "frontdoor-test" {
  name                = "frontdoor-test-plan"
  location            = "${azurerm_resource_group.frontdoor-test.location}"
  resource_group_name = "${azurerm_resource_group.frontdoor-test.name}"

  sku {
    tier = "Shared"
    size = "F1"
  }
}

resource "azurerm_app_service" "frontdoor-test" {
  name                = "frontdoor-test-app"
  location            = "${azurerm_resource_group.frontdoor-test.location}"
  resource_group_name = "${azurerm_resource_group.frontdoor-test.name}"
  app_service_plan_id = "${azurerm_app_service_plan.frontdoor-test.id}"
}

resource "azurerm_frontdoor" "frontdoor" {
  name                                         = "frontdoor-test-xp"
  location                                     = "${azurerm_resource_group.frontdoor-test.location}"
  resource_group_name                          = "${azurerm_resource_group.frontdoor-test.name}"
  enforce_backend_pools_certificate_name_check = false

  routing_rule {
      name                    = "RoutingRule1"
      accepted_protocols      = ["Http", "Https"]
      patterns_to_match       = ["/*"]
      frontend_endpoints      = ["FrontendEndpoint1"]
      forwarding_configuration {
        forwarding_protocol   = "MatchRequest"
        backend_pool_name     = "BackendWebsites"
      }
  }

  backend_pool_load_balancing {
    name = "LoadBalancingSettings1"
  }

  backend_pool_health_probe {
    name = "HealthProbeSetting1"
  }

  backend_pool {
      name            = "BackendWebsites"
      backend {
          host_header = "frontdoor-test-app.azurewebsites.net"
          address     = "frontdoor-test-app.azurewebsites.net"
          http_port   = 80
          https_port  = 443
      }

      load_balancing_name = "LoadBalancingSettings1"
      health_probe_name   = "HealthProbeSetting1"
  }

  frontend_endpoint {
    name                              = "FrontendEndpoint1"
    host_name                         = "frontdoor-test-xp.azurefd.net"
    custom_https_provisioning_enabled = false
  }
}