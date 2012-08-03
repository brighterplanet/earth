require 'earth/model'

class BtsAircraft < ActiveRecord::Base
  extend Earth::Model

  TABLE_STRUCTURE = <<-EOS

CREATE TABLE bts_aircraft
  (
     bts_code    CHARACTER VARYING(255) NOT NULL PRIMARY KEY,
     description CHARACTER VARYING(255)
  );

EOS

  self.primary_key = "bts_code"

  warn_unless_size 379
end
