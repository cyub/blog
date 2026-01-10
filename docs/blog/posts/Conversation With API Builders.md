---
title: Conversation With API Builders
date: 2016-09-13 21:55:37
tags:
    - API
---

原文链接：http://conversation.bigbinary.com/

# Conversation With API Builders
> Bad APIs have one thing in common—they do not handle response status codes effectively. 
They all use custom solutions while the status code value can be attached to the HTTP resonse.
 This ebook covers when to use what status code and much more.

## 1. Return 200 when it is all good

API user : Hey, I have a problem.

API builder : What’s wrong.

API user : I sent a request to the API to create a user. But I do not see the newly created user.

<!-- more -->

API builder : Let me check.

API builder : The email address that you sent is already taken.

API user : Hmmm..but I got 200 as the response status code.

API builder : Forget about the response code. You need to check the payload. I sent the error message as “error” key.

API user : If the system could not create the user then why did it return 200 as response status.

API builder : Because I always send 200 and I put the error message in the error key.

API user : You are doing it wrong. http status code is your friend. There are many status codes to indicate different types of errors.

API user : **A response status code in the range of 400-499 indicates that the request was not processed successfully.**

API user : A 200 response status code means that the request was processed successfully. So if the record could not be created then do not send 200.

## 2. Return 400 when the request payload is not valid

API builder : It’s fixed. Now you will get 400.

API User : But that’s wrong too.

API builder : Now what’s your problem.

API User : Send 400 when data is not syntactically correct.

API builder : What does that even mean.

API User : Let me elaborate(阐述).

API User : In order to create a user I’m sending the user data in JSON format. Right ?

API builder : Right.

API User : And the JSON that I’m sending is valid JSON. Right ?

API builder : Right.

API User : Then you can’t send 400. Because **400 should be returned when the data itself is malformed(异常).**

API builder : I see. So if the payload is not valid JSON then I could send 400.

API User : Right.

API User : If the API accepts xml and the xml is not well-formed then you can send 400.

API builder : Got it.

API builder : So what status code I should send in your case when email is taken.

API User : Let’s talk about it tomorrow.

## 3. Return 422 when the input data is not valid

API User : **422 should be used when the data is syntactically correct(语法正确) but semantically incorrect（语义错误）.**

API builder : You sure love fancy words.

API builder : Last time you talked about data being syntactically correct.

API builder : And now you are talking about semantically incorrect. Why can’t you speak simple english.

API User : “Semantically” simpley means business wise.

API User : It’s possible that the payload sent by the client is valid JSON but it is not complying with the business rules.

API User : For example in order to create a user you need name. If the payload does not provide name then it is an example of data being valid JSON data but “business-wise” it is not valid.

API User : So in other words the payload is “syntacticaly correct” but “semantically incorrect”.

API builder : That’s good to know. I will fix the code.


## 4. Return 401 when user is not authenticated(认证)

API User : API that was working last night is now returning 422.

API builder : Did you check the error message.

API User : Yes I did. And it says “you are not authenticated”.

API builder : Yes. I’m enforcing the rule that you need to be authenticated to create a user.

API User : You are enforcing the rule that’s alright but you are returning 422.

API builder : Now what’s the problem. You yourself said that if the data is “semantically incorrect” then send 422.

API User : Yes. I said that. Now you tell me if the data then I sent is valid JSON or not.

API builder : The data is indeed valid JSON. But my business rule is that you need to be authenticated.

API User : To enforce authenticatin related business rules use response status code of 401.

API User : **Use 401 when resource needs to be authenticated.**

API builder : Cool. I’m going to fix the API now.


## 5. Return 403 when user is not authorized(合法)

API User : Hi there.

API builder : Let me guess. API problem.

API User : Yes. I’m getting error message that “Only HR team can creae a new user”.

API builder : Yes. That’s the new policy. And you are not authorized to create a new user.

API User : In that case you should not send 422. You should send 403.

API builder : C'mon. Now this is getting too much. How many special status codes you have.

API User : This is the last one.

API builder : Ok. I’m listening.

API User : **If user is not authenticated then send status code 401.**

API User : **However if user is authenticated and user is forbidden then send 403.**

API User : Yes so in this case the server knows who you are. It’s just that you are not authorized to access the information you are requesting.

API builder : Got it. That is simple. Anyone who is forbidden will get 403.


## 6. Return 404 when record is not found

API User : When a record is not found then error message should be clear about what record is not found.

API User : And use status code **404 to indicate that record was not found.**

API builder : I am used to writing code like `current_user.cars.find params[:car_id]`. It raises an exception when record is not found.

API User: Yeap. That code needs slight tweaking when it is used inside an API. Rather than raising an excpetion send a clear error message when record is not found.

API builder : This is what I have right now.
```
class Api::V1::CarAlertsController < Api::V1::BaseController

  before_action :load_car

  private

  def load_car
    @car = current_user.cars.find params[:car_id]
  end

end
```
API builder : In the above code the issue is that if there is no car matching `params[:car_id]` then above code would raise `ActiveRecord::RecordNotFound` exception.

API User : Above code can be refactored to following code.
```
class Api::V1::CarAlertsController < Api::V1::BaseController

  before_action :load_car

  def show
    if @car
      ...
    else
      message = "No car was found for car_id #{params[:car_id]}."
      render  json: { error: message }, status: :not_found
    end
  end

  private

  def load_car
    @car = current_user.cars.find_by_id params[:car_id]
  end

end
```

## 7. Return 500 when an error is encountered

API User : Hi there. Long time no see.

API builder : Yes I was busy. The API code is in production now.

API User : I noticed. I got error message that something went wrong.

API builder : yes. I’m working on it.

API User : **If something goes wrong then you should send response code 500.**

API User : It means that something unexpected happened. Like an exception was raised or database could not be connected.

API User : **Even in the case of 500 system should take utmost care that returned value is valid JSON or xml.** Otherwise the client might run into problem while parsing the response body.


## 8. No need to have success key in response

I have seen a lot of APIs pass success key to indicate if the request was successfully handled or not. There is no need to do that. Response status code should be used instead.

```
# do not do this.
message = "No car was found for car_id #{params[:car_id]}."
render  json: { success: false, error: message }, status: :not_found
```

## 9. Do not use redirect in API
```
   # do not do this
  def destroy
    ....
    @user.destroy
    redirect_to :back
  end
```
In the above case `redirect_to :back` does not mean anything when you are dealing with API. The correct version would be

```
  def destroy
    ....
    @car_alert.destroy
    render head: :no_content, status: :ok
  end
```

## 10. Response should be valid JSON even when things go wrong

AU : I sent invalid JSON payload and in return I did not get valid JSON response. My mobile application crashed because I was expecting response to be valid JSON.

AB : Do you know how Rails parses JSON data.

AU : Nope.

AB : The thing is that if the payload is invalid JSON then the request does not even hit the controller.

AB : Rails attempts to parse the payload and since the paylaod is invalid it blows up up in the middleware stack.

AU : I see.

AU : Well we can write a custom middleware which will catch the exception and will return a valid JSON data.

AB : I have no idea how to do that.

AU : Ok. Here is my attempt to build it.
```
# app/middleware/catch_json_parse_errors.rb

class CatchJsonParseErrors

  def initialize app
    @app = app
  end

  def call env
    begin
      @app.call(env)
    rescue ActionDispatch::ParamsParser::ParseError => exception
      content_type_is_json?(env) ? build_response(exception) : raise(exception)
    end
  end

  private

  def content_type_is_json? env
    env['CONTENT_TYPE'] =~ /application\/json/
  end

  def error_message exception
    "Payload data is not valid JSON. Error message: #{exception}"
  end

  def build_response exception
    [ 400, { "Content-Type" => "application/json" }, [ { error: error_message(exception) }.to_json ] ]
  end

end
AU : Now we need to use this middleware. Here is how we can ask Rails to use this custom middleware.

# config/application.rb

require File.expand_path('../boot', __FILE__)
require 'rails/all'
Bundler.require(:default, Rails.env)

module Wheel
  class Application < Rails::Application
    config.middleware.insert_before ActionDispatch::ParamsParser,
                                    "CatchJsonParseErrors"
  end
end
```