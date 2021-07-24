# Saul Blumenthal
## Klaviyo Solutions Architect take-home exercise

This project implements an API that does a historical export of Shopify orders and does an import into Klaviyo for both "Placed Order" and "Ordered Product" events.

There is one endpoint, at http://saulblum-klaviyo-interview.herokuapp.com/sync-orders

### Enhancements
* Pass in specific order IDs to sync between Shopify and Klaviyo
* Enhanced error handling if the Shopify or Klaviyo APIs throw an error
