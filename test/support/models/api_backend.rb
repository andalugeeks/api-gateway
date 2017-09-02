class ApiBackend < ApplicationRecord
  has_one :settings, :class_name => "ApiBackendSettings"
  has_many :servers, :class_name => "ApiBackendServer"
  has_many :url_matches, :class_name => "ApiBackendUrlMatch"
  has_many :sub_settings, :class_name => "ApiBackendSubUrlSettings"
  has_many :rewrites, :class_name => "ApiBackendRewrite"

  def roles
    roles = []

    if(self.settings && self.settings.required_roles)
      roles += self.settings.required_roles
    end

    if(self.sub_settings)
      self.sub_settings.each do |sub|
        if(sub.settings && sub.settings.required_roles)
          roles += sub.settings.required_roles
        end
      end
    end

    roles.uniq!
    roles
  end

  def serializable_hash(options = nil)
    options ||= {}
    options.merge!({
      :include => {
        :settings => {
          :include => {
            :http_headers => {},
            :rate_limits => {},
          },
        },
        :servers => {},
        :url_matches => {},
        :sub_settings => {
          :include => {
            :settings => {
              :include => {
                :http_headers => {},
                :rate_limits => {},
              },
            },
          },
        },
        :rewrites => {},
      },
    })
    super(options)
  end
end
