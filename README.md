# Saul Blumenthal
## Klaviyo Solutions Architect take-home exercise

This project implements an API that does a historical export of Shopify orders and does an import into Klaviyo for both "Placed Order" and "Ordered Product" events.

There is one endpoint, at http://saulblum-klaviyo-interview.herokuapp.com/sync-orders

![image](https://user-images.githubusercontent.com/52899130/126853843-01242cb7-ac16-4fc0-835c-fb6a7f0ae90b.png)

### Enhancements
* Pass in specific order IDs to sync between Shopify and Klaviyo
* Enhanced error handling if the Shopify or Klaviyo APIs throw an error
