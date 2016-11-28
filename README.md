TODO
* change internal options back into a hash?
* make multiple errors per key possible
* create atom errors inside of key filter rather than collection filter
* allow errors on collections with "base" errors
* add block to model filter to check methods of a passed model
* create builder filter

Optional Options
* **discard_nil**
* **discard_empty**
* **discard_invalid**

Global Filter Options
* **nils**
  * nil (default): invalid when data is nil
  * true: allows nil data to be valid
* **strict**
  * nil (default): allows type coercion
  * true: disables type coercion

Options
* **format**
  * nil (default): uses `Time.parse(`data`)`
  * String: uses `Time.strptime(`data`, `given`)`
* **allow_control_characters**
  * false (default): removes unprintable characters using `.gsub(/[^[:print:]\t\r\n]+/, ' ')`
  * true: does nothing
* **strip**
  * true (default): uses data`.strip`
  * false: does nothing
* **class(ModelFilter)**
  * nil (default): uses attribute name`.to_s.camelize.constantize`
  * String: uses given`.constantize`
  * Constant: uses given
* **new_records**
  * false (default): `#new_record?` must return true if the model responds to it
  * true: unsaved models are valid
* **wrap(ArrayFilter)**
  * false (default): does nothing
  * true: uses `Array.wrap(`data`)`
* **min**
  * nil (default): does nothing
  * self: given must be >= value
* **max**
  * nil (default): does nothing
  * self: given must be <= value
* **before**
  * nil (default): does nothing
  * self: given must be <= value
* **after**
  * nil (default): does nothing
  * self: given must be >= value
* **scale**
  * nil (default): does nothing
  * Integer: validates data has no more decimal places than the given
* **methods**
  * nil (default): does nothing
  * Symbol: validates data responds to method
  * Array(<Symbol>): validates data responds to each method
* **upload**
  * false (default): does nothing
  * true: data must respond to `#original_filename` and `#content_type`
* **size**
  * nil (default): does nothing
  * Integer: validates data is no larger than the given number of bytes
* **in**
  * nil (default): does nothing
  * Array: data must be included in the given array
* **matches**
  * nil (default): does nothing
  * RegExp: ensures data matches given regexp pattern

Tips And Tricks
* model constants
  * implied and string classes are constantized with every feed - good if constants are ever removed and recreated
  * pass in a constant with the `class` option to get a performance boost - bad if constants are ever removed
  * FYI - a `nil` value with short circuit the check for a valid constant
