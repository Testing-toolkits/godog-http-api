Feature: Test for User's CRUD.
  User's CRUD API binary and it's documentation can be found in assets/test_server/ directory.
  It is simple web server with endpoints:
  - POST    /users            - creates new user
  - GET     /users            - retrieve all users
  - GET     /users/{user_id}  - retrieve user by user_id
  - PUT     /users/{user_id}  - replace user by user_id
  - DELETE  /users/{user_id}  - delete user by user_id

  Background:
  This section runs before every Scenario.
  Its main purpose is to generate random:
  - first name,
  - last name,
  - age.
  and save it under provided key in scenario cache.

    Given I generate a random string in the range from "5" to "15" without unicode characters and save it as "RANDOM_FIRST_NAME"
    Given I generate a random string in the range from "5" to "15" with unicode characters and save it as "RANDOM_LAST_NAME"
    Given I generate a random int in the range from "18" to "48" and save it as "RANDOM_AGE"

  Scenario: Get single user
  As application user
  I would like to store random user's data
  and then obtain this data

    #---------------------------------------------------------------------------------------------------
    # We send HTTP(s) request with pre-generated data to create new user
    # Notice, we use pre-generated values(from Background section above)
    # using go templates syntax from text/template package.
    When I send "POST" request to "{{.MY_APP_URL}}/users" with body and headers:
    """
    {
        "body": {
            "firstName": "{{.RANDOM_FIRST_NAME}}",
            "lastName": "{{.RANDOM_LAST_NAME}}",
            "age": {{.RANDOM_AGE}}
        },
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    Then the response status code should be 201
    And the response should have header "Content-Type" of value "application/json; charset=UTF-8"
    And the response body should have type "JSON"
    And the response body should be valid according to JSON schema "user/get_user.json"
    And I save from the last response JSON node "id" as "USER_ID"

    #---------------------------------------------------------------------------------------------------
    # We send HTTP(s) request to obtain previously created user
    When I send "GET" request to "{{.MY_APP_URL}}/users/{{.USER_ID}}" with body and headers:
    """
    {
        "body": {},
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    Then the response status code should be 200
    And the response should have header "Content-Type" of value "application/json; charset=UTF-8"
    And the response body should have type "JSON"
    And the response body should be valid according to JSON schema "user/get_user.json"

    #---------------------------------------------------------------------------------------------------
    # Here, we check assertions against response body
    #
    # node argument should be pattern valid to qjson library, for example:
    # - data.user[0].firstName    - {"data": [{"firstName": "abc", "lastName": "cdf", age:30}, {...}]}
    # - root[0].city[1].size      - [{"name": "Lublin", "size": 10000}, {"name": "Warsaw", "size": 20000}]
    # - firstName                 - {"firstName": "abc", "lastName": "cdf", age:30},
    #
    # data type should be one of: string|int|float|bool
    #
    # node value may be fixed or obtained from cache using syntax from go text/template package
    And the JSON node "firstName" should be "string" of value "{{.RANDOM_FIRST_NAME}}"
    And the JSON node "lastName" should be "string" of value "{{.RANDOM_LAST_NAME}}"
    And the JSON node "age" should be "int" of value "{{.RANDOM_AGE}}"
    And the JSON node "id" should be "int" of value "{{.USER_ID}}"
