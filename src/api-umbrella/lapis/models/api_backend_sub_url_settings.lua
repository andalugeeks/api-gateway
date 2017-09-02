local json_null = require("cjson").null
local model_ext = require "api-umbrella.utils.model_ext"
local t = require("resty.gettext").gettext
local validation_ext = require "api-umbrella.utils.validation_ext"

local validate_field = model_ext.validate_field

local ApiBackendSubUrlSettings = model_ext.new_class("api_backend_sub_url_settings", {
  relations = {
    { "settings", has_one = "ApiBackendSettings", key = "api_backend_sub_url_settings_id" },
  },

  as_json = function(self)
    local data = {
      id = self.id or json_null,
      http_method = self.http_method or json_null,
      regex = self.regex or json_null,
      settings = json_null,
    }

    local settings = self:get_settings()
    if settings then
      data["settings"] = settings:as_json()
    end

    return data
  end,
}, {
  validate = function(_, data)
    local errors = {}
    validate_field(errors, data, "http_method", validation_ext:regex("^(any|GET|POST|PUT|DELETE|HEAD|TRACE|OPTIONS|CONNECT|PATCH)$", "jo"), t("is not included in the list"))
    validate_field(errors, data, "regex", validation_ext.string:minlen(1), t("can't be blank"))
    return errors
  end,

  after_save = function(self, values)
    model_ext.has_one_save(self, values, "settings")
  end,
})

return ApiBackendSubUrlSettings
