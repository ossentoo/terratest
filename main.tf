resource "azurerm_resource_group" "frontdoor_test" {
  name     = "frontdoor_test"
  location = "UK West"

  tags = {
    environment = "Development"
  }
}

resource "azurerm_app_service_plan" "frontdoor_test" {
  name                = "frontdoor-test-plan"
  location            = "${azurerm_resource_group.frontdoor_test.location}"
  resource_group_name = "${azurerm_resource_group.frontdoor_test.name}"

  sku {
    tier = "Shared"
    size = "F1"
  }
}

resource "azurerm_app_service" "frontdoor_test" {
  name                = "frontdoor-test-app"
  location            = "${azurerm_resource_group.frontdoor_test.location}"
  resource_group_name = "${azurerm_resource_group.frontdoor_test.name}"
  app_service_plan_id = "${azurerm_app_service_plan.frontdoor_test.id}"
}
