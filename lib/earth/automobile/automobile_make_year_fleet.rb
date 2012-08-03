require 'earth/model'

class AutomobileMakeYearFleet < ActiveRecord::Base
  extend Earth::Model

  TABLE_STRUCTURE = <<-EOS

CREATE TABLE automobile_make_year_fleets
  (
     name                  CHARACTER VARYING(255) NOT NULL PRIMARY KEY,
     make_name             CHARACTER VARYING(255),
     year                  INTEGER,
     fleet                 CHARACTER VARYING(255),
     fuel_efficiency       FLOAT,
     fuel_efficiency_units CHARACTER VARYING(255),
     volume                INTEGER
  );

EOS

  self.primary_key = "name"
  
  
  warn_unless_size 1349
end
