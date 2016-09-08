TODO
* allow strict as an option to for all filters

Issues
* arrayize converts `''` into `[]` rather than `['']`

Optional Options
* **discard_nil**
* **discard_empty**
* **discard_invalid**

Options
* **empty_is_nil**
  * false (default): does nothing
  * true: treats `''` data as if it were `nil`
* **nils**
  * false (default): invalid when data is nil
  * true: allows nil data to be valid
* **strict**
  * false (default): allows type coercion
  * true: disables type coercion
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
* **builder**
  * nil (default): does nothing
  * String: uses given`.constantize.run(...)` if passed a hash
  * Constant: uses given`.run(...)` if passed a hash
* **new_records**
  * false (default): `#new_record?` must return true if the model responds to it
  * true: unsaved models are valid
* **arrayize(ArrayFilter)**
  * false (default): does nothing
  * true: uses `Array(`data`)`
* **min**
  * nil (default): does nothing
  * self: given must be >= value
* **min_length**
  * nil (default): does nothing
  * self: given must be >= value
* **after**
  * nil (default): does nothing
  * self: given must be >= value
* **max**
  * nil (default): does nothing
  * self: given must be <= value
* **max_length**
  * nil (default): does nothing
  * self: given must be <= value
* **before**
  * nil (default): does nothing
  * self: given must be <= value
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
