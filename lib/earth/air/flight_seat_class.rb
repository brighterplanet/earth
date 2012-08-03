require 'earth/model'

class FlightSeatClass < ActiveRecord::Base
  extend Earth::Model

  TABLE_STRUCTURE = <<-EOS

CREATE TABLE flight_seat_classes
  (
     name CHARACTER VARYING(255) NOT NULL PRIMARY KEY
  );

EOS

  self.primary_key = "name"
  

  warn_unless_size 4
end
