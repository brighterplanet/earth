require 'earth/model'

class NationalTransitDatabaseMode < ActiveRecord::Base
  extend Earth::Model

  TABLE_STRUCTURE = <<-EOS

CREATE TABLE ntd_modes
  (
     code      CHARACTER VARYING(255) NOT NULL PRIMARY KEY,
     name      CHARACTER VARYING(255),
     rail_mode BOOLEAN
  );

EOS

  self.primary_key = "code"
  self.table_name = :ntd_modes
  
  def self.rail_modes
    where(:rail_mode => true)
  end
  

  warn_unless_size 14
end
