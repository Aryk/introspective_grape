
0.2.8 01/22/2017
==============

Nested endpoints for creating new associations will now return only the newly created records.

0.2.7 01/18/2017
==============

Add support for Swagger 2+, we can now support the latest versions of grape and other dependencies.


0.2.6 11/01/2016
==============

Change the Model.attribute_param_types class method lookup (for specifying custom param types attributes on a model) to "grape_param_types" to make it clearer that the method is used in the API.

### Features

Add support for custom validations on a model using a `self.grape_validations` hash of fields and validations to apply.

Add custom validators to verify that JSON strings parse as a JSON object, an array, or a hash.


0.2.5 10/28/2016
==============

### Bug Fix

Include the nested model IDs in the swagger doc.

0.2.4 10/26/2016
==============

### Bug Fix

Validate the presence of required belongs_to associations.

### Features

Add a default_sort for the index action option, rather than relying on custom_filters or a default_scope.

0.2.3 10/21/2016
==============
### Bug Fix

We have to modify request.params and then re-assign @params to request.params before
validation in order to work with Grape's habit of mucking with both independently.

This makes Grape validations work properly again against camel inputs.

0.2.2 10/20/2016
==============

### Bug Fix

The default pagination values for Kaminari in snake case were overwriting the passed values
in camel case, update the camel_snake_keys dependency so key conflicts resolve in favor of
the expected convention.

0.2.1 10/20/2016
==============

Require explicit declarations for index filters using `filter_on :attribute`. Automatically generate filters on all fields as before using `filter_on :all`.

Defer endpoint documentation to <action>_documentation class methods on the API, so docs can be written.

0.2.0 10/12/2016
==============

### Features

Allow index action filter overrides if there is a class-level 'assignment' method on the field

Allow custom filters, e.g.:

class MyAPI < IntrospectiveGrape::API
  custom_filter :my_filter, {type: Boolean, description: "Filter on some scope" }

  restful MyModel, [my_field]
end

class MyModel
  self << class
    def my_filter(filter=false)
      filter ? my_scope : where(nil)
    end
    
    def my_field=(parameters)
      # parse the passed parameters in some fancy way and return a query scope
    end
  end 
end

0.1.9 9/27/2016
==============
### Features

Allow identifier filters for foreign and primary keys to accept comma separated lists.

0.1.8 9/25/2016
==============

### Features

Add date range filters for the index page.

0.1.6 9/10/2016
==============

### Bug Fix

The before hook snake casing parameters in the API was preventing the assignment of default values, this was moved to an after_validation hook.

### Features

Grape::Kaminari pagination was added to the index actions if configured in the parent class.

0.1.5 6/26/2016
==============

### Bug Fix

Reload the model from the database before presenting it to the user after create/update, as
some deeply nested association changes will not be properly loaded by active record.

0.1.4 5/11/2016
==============

### Features

Added an include_actions declaration as the inverse of exclude_actions.

0.1.1 5/11/2016
==============

### Features

Stop monkey patching Grape's json formatter and instead use Grape's "formatter" 
with our own CamelJson module.

0.1.0 5/8/2016
==============

### Features

Add simple filter for index endpoints.

### Fixes

Refactor API generation to reduce the code complexity.
