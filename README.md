# Burger-Online-Delivery-study-case

This project is to holistically apply swift app development knowledge

## BDD Scenarios

### Narrative #1

```
As a online customer
I want the app to automatically load all my latest menu
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
   * MAX_AGE: 14 days
   
#### Primary course (happy path):
   1. Execute "Load Burger Menu" command with above data.
   2. System retrieves menu data from the cache.
   3. System validates cache is less than MAX_AGE old.
   4. System validates cache is less than two weeks old.
   5. System delivers cached feed data.

#### Retrieval error course (sad path):
   1. System delivers error.

#### Empty cache (sad path):
   1. System delivers connectivity error.
   
#### Expired cache course (sad path):
   1. System deletes cache.
   2. System delivers no menu.
   
---

### Cache Feed Use Case

#### Data
   * Burger Items
   
#### Primary course (happy path):
   1. Execute "Save Burger Menu" command with above data.
   2. System encodes burger items.
   3. System timestamp new cache.
   4. System delete the old cache dat.
   5. System saves the new cache data.
   6. System delivers success message.

#### Deleting error course (sad path):
   1. System delivers error.
   
#### Saving error course (sad path):
   1. System delivers error.
   
   
## Flowchart
![image](https://drive.google.com/uc?export=view&id=1p6TjTjornO5K6Gn0RrEx8vW40s5VAdWh)

## Architecture
<img width="530" alt="Screen Shot 2020-06-26 at 8 57 14 AM" src="https://user-images.githubusercontent.com/19692076/85865241-3540d580-b78b-11ea-965e-303f38fa8b17.png">

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
