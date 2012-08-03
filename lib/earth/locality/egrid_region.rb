require 'falls_back_on'

require 'earth/model'

require 'earth/locality/egrid_country'
require 'earth/locality/egrid_subregion'

class EgridRegion < ActiveRecord::Base
  extend Earth::Model

  TABLE_STRUCTURE = <<-EOS

CREATE TABLE egrid_regions
  (
     name                       CHARACTER VARYING(255) NOT NULL PRIMARY KEY,
     generation                 FLOAT,
     generation_units           CHARACTER VARYING(255),
     foreign_interchange        FLOAT,
     foreign_interchange_units  CHARACTER VARYING(255),
     domestic_interchange       FLOAT,
     domestic_interchange_units CHARACTER VARYING(255),
     consumption                FLOAT,
     consumption_units          CHARACTER VARYING(255),
     loss_factor                FLOAT
  );

EOS

  self.primary_key = "name"
  
  # EgridCountry must be a parent so that it automatically gets data_mined (needed for fallback calculation)
  belongs_to :egrid_country, :foreign_key => 'country_name'
  has_many :egrid_subregions, :foreign_key => 'egrid_region_name'
  
  falls_back_on :name => 'fallback',
                :loss_factor => lambda { EgridCountry.us.loss_factor }
  
  
  warn_unless_size 5
  warn_if_any_nulls
end
