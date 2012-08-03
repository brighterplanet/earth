require 'earth/model'

class ResidenceAppliance < ActiveRecord::Base
  extend Earth::Model

  TABLE_STRUCTURE = <<-EOS

CREATE TABLE residence_appliances
  (
     name                                 CHARACTER VARYING(255) NOT NULL PRIMARY KEY,
     annual_energy_from_electricity       FLOAT,
     annual_energy_from_electricity_units CHARACTER VARYING(255)
  );

EOS

  self.primary_key = "name"

  class << self
    def annual_energy_from_electricity_for(appliance_plural)
      appliance_name = appliance_plural.to_s.singularize
      if appliance = find_by_name(appliance_name)
        appliance.annual_energy_from_electricity
      end
    end
  end


  warn_unless_size 2
end
