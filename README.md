# Saul Blumenthal
## Klaviyo Solutions Architect take-home exercise

This project implements an API that does a historical export of Shopify orders and does an import into Klaviyo for both "Placed Order" and "Ordered Product" events.

There is one endpoint, at http://saulblum-klaviyo-interview.herokuapp.com/sync-orders

It takes one optional query string param `since` that adds the param `created_at_min` to the Shopify orders API call; without the param, the Shopify API will return all orders.

![image](https://user-images.githubusercontent.com/52899130/126853843-01242cb7-ac16-4fc0-835c-fb6a7f0ae90b.png)

### How I approached the assignment
I first read the Shopify and Klaviyo documentation and used Postman to make sample API calls. I kept getting `0` as the Klaviyo response till I realized, from the documentation examples, that I had to prefix the JSON body with `data=`.

I then decided which parameters I might want to include when designing an API to sync Shopify to Klaviyo, and settled on one parameter for now, a `since` date that sets the earliest orders that Shopify will return.

I created a local Rails app with an `Orders` controller and a `sync-orders` route, and deployed the app to Heroku.

### Security
The Shopify and Klaviyo API keys are stored as environment variables (not committed to Github) and as config variables in Heroku:

![image](https://user-images.githubusercontent.com/52899130/126854004-c83d1da9-d259-424b-8099-aaf35491194c.png)

The API is authenticated by an `Authorization` header, whose value I will email:

![image](https://user-images.githubusercontent.com/52899130/126854101-c748f170-217e-4546-bd70-fe5b8f1bfacb.png)

Without the correct header, the API will return a 403:

![image](https://user-images.githubusercontent.com/52899130/126854242-69fc1f1a-8a7a-4dd5-90b9-ef569508aa17.png)

**Question about the Klaviyo keys**

Only the public key is needed to make the Klaviyo API calls, and the [documentation](https://help.klaviyo.com/hc/en-us/articles/115005062267-How-to-Manage-Your-Account-s-API-Keys) says, "It is safe to expose your public API key, as this key cannot be used to access data in your Klaviyo account." What would stop someone from making these "Placed Order" and "Ordered Product" calls with only the public key?

### Enhancements
* Pass in specific order IDs to sync between Shopify and Klaviyo
* Specify which custom order and product properties should be synced, besides the standard properties
* Enhanced error handling if the Shopify or Klaviyo APIs throw an error
