# Objective
[![Build Status](https://travis-ci.org/dallincrane/objective.svg)](https://travis-ci.org/dallincrane/objective)

Write safe and maintainable code by creating modular units of business logic where all inputs are sanitized and validated.

We call these modular units objectives.

## Installation

`gem install objective`

## The Basics

An objective has four steps
1. Filter
2. Coerce
2. Validate
3. Run

#### Creating an Objective

```ruby
# Define an objective that creates a user
class CreateUser
  include Objective::Unit

  # input filtering, coercion, and basic validations are defined here
  filter do
    string :name
    date :birthday, nils: ALLOW
    hash :settings do
      string :home_page, nils: DISCARD
      integer :version, none: 2
    end
  end

  def validate
    # add extra validations here
  end

  # the execute method will run only if the inputs are valid
  def execute
    user = User.create!(inputs) # inputs is provided by the filter above
    UserMailer.async(:deliver_welcome, user.id)
    user
  end
end
```

#### Running An Objective
Generally speaking:

```ruby
CreateUser.run(args) #<Objective::Outcome >
# or
CreateUser.run!(args) #<User >
```

For example, in a controller action you can use it like so:

```ruby
def create
  # run the objective
  outcome = CreateUser.run(params[:user])

  # Then check to see if it worked
  if outcome.success?
    render json: { message: "Great success, #{outcome.result.name}!" }
  else
    render json: outcome.errors.symbolic, status: 422
  end
end
```

Alternatively, if you're confident in the success of an objective or prefer catching an error, you can ask for the result of `execute` directly by using `#run!`

```ruby
def create
  user = CreateUser.run!(params) # returns the result of execute, or raises Objective::ValidationError
  render json: { message: "Great success, #{user.name}!" }
end
```

#### Things to Note

* We don't need strong params or attr_accessible to protect against mass assignment attacks
* We are guaranteed that within the execute method or, any other instance method, that the inputs will be the correct data types. This is true even if they needed some coercion. See the wiki on [filters](https://github.com/dallincrane/objective/wiki/Filters) for more information
* We don't need ActiveRecord validations
* We don't need callbacks on our models -- everything is in the execute method (helper methods are also encouraged)
* The code is completely re-usable in other contexts (need an API?)
* The arguments required for this objective 'function' are explicit and easy to read by other developers

## Why They Are Called Objectives

Imagine you had a folder in your Rails project:

  app/objectives

And inside, you had a library of business operations that you can do against your datastore:

  app/objectives/users/signup.rb
  app/objectives/users/login.rb
  app/objectives/users/update_profile.rb
  app/objectives/users/change_password.rb
  ...
  app/objectives/articles/create.rb
  app/objectives/articles/update.rb
  app/objectives/articles/publish.rb
  app/objectives/articles/comment.rb
  ...
  app/objectives/ideas/upsert.rb
  ...

Each of these _objectives_ takes your application from one task or state to the next.

## Passing Arguments to Objectives

Objectives only accept hashes as arguments to #run and #run!

That being said, you can pass multiple hashes to run, and they are merged together. Later hashes take precedence. This gives you safety in situations where you want to pass unsafe user inputs and safe server inputs into a single objective. For instance:

```ruby
# A user comments on an article
class CreateComment
  include Objective::Unit

  filter do
    model :user
    model :article
    string :comment, max: 500
  end

  def execute
    # ...
  end
end
```

Then from a controller for example:

```ruby
def create
  outcome = CreateComment.run(
    params[:comment],
    user: current_user,
    article: Article.find(params[:article_id])
  )
  # ...
end
```

Here, we pass two hashes to CreateComment. Even if the params[:comment] hash has a user or article field, they're overwritten by the second hash. (Also note: even if they weren't, they couldn't be of the correct data type in this particular case.)

## Defining Objectives

1. Create a class and include Objective::Unit

  ```ruby
  class CreateObjective
    include Objective::Unit
    # ...
  end
  ```

1. Define your inputs and their validations:

  ```ruby
  filter do
    string :name, max: 10
    string :state, in: %w[AL AK AR ... WY]
    integer :age
    boolean :is_special, none: true
    model :account
    array :tags, none: ALLOW do
      string
    end
    hash :prefs, none: ALLOW do
      boolean :smoking
      boolean :view
    end
  end
  ```

  See a full list of filter options [here](https://github.com/dallincrane/objective/wiki/Filters).

1. Define your execute method. It can return a value:

  ```ruby
  def execute
    record = do_thing(inputs)
    # ...
    record
  end
  ```

## Writing an `execute` Method

Your execute method, and any other instance methods, have access to the inputs filtered by the objective:

```ruby
def execute
  inputs # openstruct of all arguments passed to #run
end
```

Further, an attr_accessor is set for each top level input key.  
If you define an input called _email_, then it would be available to you as a method:

```ruby
def execute
  p email # email value passed in
end
```

You can do validation inside of execute or any other instance method  
(NOTE: custom validations should be done in #validate if possible)

```ruby
if email =~ /aol.com/
  add_error(:email, :old_school, "Wow, you still use AOL?")
  return
end
```

You can return a value as the result of running the objective:

```ruby
def execute
  # ...
  'WIN!'
end

# Get result:
outcome = YourObjective.run(...)
outcome.result # => 'WIN!'
# or
YourObjective.run!(...) # => 'WIN!'
```

## Validation Errors

If things don't pan out, you'll get back an Objective::Errors::ErrorHash object that maps invalid inputs to either symbols or messages. For example:

```ruby
# Didn't pass required field 'email', and newsletter_subscribe is the wrong format:
outcome = CreateUser.run(name: "Bob", newsletter_subscribe: "Wat")

unless outcome.success?
  outcome.errors.symbolic # => {email: :required, newsletter_subscribe: :boolean}
  outcome.errors.message # => {email: "Email is required", newsletter_subscribe: "Newsletter Subscription isn't a boolean"}
  outcome.errors.message_list # => ["Email is required", "Newsletter Subscription isn't a boolean"]
end
```

**You can add errors in a `validate` method if the filter validations are insufficient.**  
**Errors added by validate will prevent the `execute` method from running.**

```ruby
#...
def validate
  if password != password_confirmation
    add_error(:password_confirmation, :mismatch, "Your passwords don't match")
  end
end
# ...

# That error would show up in the errors hash:
outcome.errors.symbolic # => {password_confirmation: :mismatch}
outcome.errors.message # => {password_confirmation: "Your passwords don't match"}
```

Alternatively you can also add these validations in the execute method:

```ruby
#...
def execute
  if password != password_confirmation
    add_error(:password_confirmation, :mismatch, "Your passwords don't match")
    return
  end
end
# ...

# That error would show up in the errors hash:
outcome.errors.symbolic # => {password_confirmation: :mismatch}
outcome.errors.message # => {password_confirmation: "Your passwords don't match"}
```

If you want to tie the validation messages into your I18n system, you'll need to [write a custom error message generator](https://github.com/dallincrane/objective/wiki/Custom-Error-Messages).

## FAQs

### Is this better than the 'Rails Way'?

Rails comes with an awesome default stack, and a lot of standard practices that folks use are very reasonable for certain use cases (eg. thin controllers, fat models).

That being said, there are many patterns available. As your Rails app grows in size and complexity, using like those found within this gem can help your app immensely.

### How do I share code between objectives?

Put code that can be shared across objectives into module(s) that can then be included into those different objectives.

### Can I subclass my objectives?

Yes, however, using multiple layers of objectives (running an objective within another objective) is generally cleaner and and easier to maintain.

### Can I use this with Rails forms helpers?

Somewhat. Any form can be sent to your server, and objectives are great at accepting that input. However, if there are errors, there's no built-in way to bake the errors into the HTML with Rails form tag helpers. Right now this is really designed to support a JSON API.  You'd probably have to write an adapter of some kind.

## Acknowledgements

This gem is largely based on the [mutations](https://github.com/cypriss/mutations) gem by cypriss. Along with the general idea, this README as well as a portion of the code was adapted from their work. There are, however, significant differences.
