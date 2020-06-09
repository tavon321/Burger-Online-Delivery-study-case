# Burger-Online-Delivery-study-case

This project is to holistically apply aswift app develeopment knowledge

## BDD Scenarios

### Narrative #1

```
As a online customer
I want the app to automatically laod all my latest menu
So i can always try something new on the restaurant
```

#### Scenario 
```
Given the customer has connectivity
   When the customer requests to see oue menu
      Then the app should display the latest menu from remote
        And replace the cache with the new menu    
```

### Narrative #2

```
As a offline customer
I want the app to show the latest saved version of my menu
So I can beging looking for a dish until the connection is back.
```

#### Scenario 
```
Given the customer doesn't have connectivity
  And there’s a cached version of the menu
  And the cache is less than two weeks old
 When the customer requests to see the menu
  Then the app should display the latest menu saved

Given the customer doesn't have connectivity
  And there’s a cached version of the menu
    And the cache is two weeks old or more
 When the customer requests to see the menu
  Then the app should display an error message

Given the customer doesn't have connectivity
  And the cache is empty
 When the customer requests to see the menu
   Then the app should display an error message 
```

## Use Cases

### Load Menu From Remote Use Case

#### Data
   * URL
   
#### Primary course (happy path):
   1. Execute "Load Burger Menu" command with above data.
   1. System downloads data from the URL.
   1. System validates downloaded data.
   1. System creates menu from valid data.
   1. System delivers menu.

#### Invalid data – error course (sad path):
   1. System delivers invalid data error.

#### No connectivity – error course (sad path):
   1. System delivers connectivity error.

---

### Load Burger Image Data From Remote Use Case

### Data
   * URL
   
#### Primary course (happy path):
   1. Execute "Load Burger Image" command with above data.
   1. System downloads data from the URL.
   1. System validates downloaded data.
   1. System creates menu from valid data.
   1. System delivers menu.

#### Invalid data – error course (sad path):
   1. System delivers invalid data error.

#### No connectivity – error course (sad path):
   1. System delivers connectivity error.
   
---

### Load Menu From Cache Use Case

#### Data
   * URL
   
#### Primary course (happy path):
   1. Execute "Load Burger Menu" command with above data.
   1. System retrieves menu data from the cache.
   1. System validates cache is less than two weeks old.
   1. System delivers cached feed data.

#### Retrieval error course (sad path):
   1. System delivers invalid data error.

#### Empty cache (sad path):
   1. System delivers connectivity error.
   
#### Expired cache course (sad path):
   1. System delivers no menu.
   
## Flowchart
![Screen Shot 2020-06-08 at 8 15 58 AM](https://user-images.githubusercontent.com/19692076/84034707-51a5db00-a960-11ea-96d3-8ec07da7b6d5.png)

## Architecture
![Screen Shot 2020-06-05 at 8 59 55 AM](https://user-images.githubusercontent.com/19692076/83884727-f202c200-a70a-11ea-8ca6-c682cb32c9ab.png)

## Model Specs

### Burger Item

| Property  | Type |
| ------------- | ------------- |
| id  | UUID  |
| name  | String  |
| description  | String? |
| image  | URL?  |

### Payload contract
```
GET *url* (TBD)

200 RESPONSE

{
	"items": [
		{
			"id": "a UUID",
			"name": "a burger name",
			"description": "a description",
			"image": "https://a-image.url",
		},
		{
			"id": "another UUID",
			"name": "a burger name"
		},
		{
			"id": "another UUID",
			"name": "a burger name",
			"description": "another description"
		},
		{
			"id": "another UUID",
			"name": "a burger name",
			"image": "https://a-image.url"
		}
		...
	]
}
```
