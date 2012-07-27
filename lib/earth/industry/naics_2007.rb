require 'earth/model'

class Naics2007 < ActiveRecord::Base
  extend Earth::Model

  TABLE_STRUCTURE = <<-EOS
CREATE TABLE "naics_2007"
  (
     "code"        CHARACTER VARYING(255) NOT NULL,
     "description" CHARACTER VARYING(255)
  );
ALTER TABLE "naics_2007" ADD PRIMARY KEY ("code")
EOS

  self.primary_key = "code"
  self.table_name = "naics_2007"
  
  has_many :naics_2002_naics_2007_concordances, :foreign_key => :naics_2007_code
  has_many :naics_2002, :through => :naics_2002_naics_2007_concordances
  
end
