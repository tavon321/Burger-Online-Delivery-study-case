# Burger-Online-Delivery-study-case
This project is to holistically apply aswift app develeopment knowledge

# BDD Scenarios

## Narrative #1

```
As a online customer
I want the app to automatically laod all my latest menu
So i can always try something new on the restaurant
```

### Scenario 
```
Given the customer has connectivity
   When the customer requests to see oue menu
      Then the app should display the latest menu from remote
        And replace the cache with the new menu    
```

## Narrative #2

```
As a offline customer
I want the app to show the latest saved version of my menu
So I can beging looking for a dish until the connection is back.
```

### Scenario 
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

# Use Cases

## Load Feed From Remote Use Case

### Data
   * URL
   
### Primary course (happy path):
   1. Execute "Load Burger Menu" command with above data.
   1. System downloads data from the URL.
   1. System validates downloaded data.
   1. System creates menu from valid data.
   1. System delivers menu.

### Invalid data – error course (sad path):
   1. System delivers invalid data error.

### No connectivity – error course (sad path):
   1. System delivers connectivity error.

## Load Burger Image Data From Remote Use Case

### Data
   * URL
   
### Primary course (happy path):
   1. Execute "Load Burger Image" command with above data.
   1. System downloads data from the URL.
   1. System validates downloaded data.
   1. System creates menu from valid data.
   1. System delivers menu.

### Invalid data – error course (sad path):
   1. System delivers invalid data error.

### No connectivity – error course (sad path):
   1. System delivers connectivity error.
  
