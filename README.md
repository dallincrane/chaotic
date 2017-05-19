## Creating An Objective
```ruby
class CreateUser
  include Objective::Unit

  filter do
    string :name
    date :birthday, nils: ALLOW
    hash :settings do
      string :home_page, nils: DISCARD
      decimal :pi, none: 3.14
    end
  end

  def validate
    # add extra validations here
  end

  def execute
    inputs # => filtered data available via :inputs attr_reader
    User.create!(inputs)
  end
end
```

## Running A Objective Class
```ruby
CreateUser.run(params)
# or
CreateUser.run!(params) # <User >
```

### Filter Options  
__option default value listed first__   
_none_ means that a key on the options hash is not present


## Global Options
* **none**
  * ALLOW: allows data to not be provided but still valid
  * DENY: makes data invalid when value is not provided
  * (anything else): becomes a default value for when a value is not provided
* **nils**
  * ALLOW: allows nil data to be valid
  * DENY: makes nil data invalid
  * DISCARD: removes key from input data altogether
  * (anything else): replaces data when nil, like a default value
* **strict**
  * != true: allows type coercion
  * true: disables type coercion

## Options
* **format**
  * nil: uses `Time.parse(`data`)`
  * String: uses `Time.strptime(`data`, `given`)`
* **allow_control_characters**
  * false: removes unprintable characters using `.gsub(/[^[:print:]\t\r\n]+/, ' ')`
  * true: does nothing
* **strip**
  * true: uses data`.strip`
  * false: does nothing
* **class(ModelFilter)**
  * nil: uses attribute name`.to_s.camelize.constantize`
  * String: uses given`.constantize`
  * Constant: uses given
* **new_records**
  * false: `#new_record?` must return true if the model responds to it
  * true: unsaved models are valid
* **wrap(ArrayFilter)**
  * false: does nothing
  * true: uses `Array.wrap(`data`)`
* **min**
  * nil: does nothing
  * self: given must be >= value
* **max**
  * nil: does nothing
  * self: given must be <= value
* **before**
  * nil: does nothing
  * self: given must be <= value
* **after**
  * nil: does nothing
  * self: given must be >= value
* **scale**
  * nil: does nothing
  * Integer: validates data has no more decimal places than the given
* **methods**
  * nil: does nothing
  * Symbol: validates data responds to method
  * Array(<Symbol>): validates data responds to each method
* **upload**
  * false: does nothing
  * true: data must respond to `#original_filename` and `#content_type`
* **size**
  * nil: does nothing
  * Integer: validates data is no larger than the given number of bytes
* **in**
  * nil: does nothing
  * Array: data must be included in the given array
* **matches**
  * nil: does nothing
  * RegExp: ensures data matches given regexp pattern

### Tips And Tricks
* model constants
  * implied and string classes are constantized with every feed - good if constants are ever removed and recreated
  * pass in a constant with the `class` option to get a performance boost - bad if constants are ever removed
  * FYI - a `nil` value will short circuit the check for a valid constant

TODO
* handle zero length strings
* make multiple errors per key possible
* create atom errors inside of key filter rather than collection filter
* allow errors on collections with "base" errors
* add block to model filter to check methods of a passed model
* create builder filter
* add squish to string filter
