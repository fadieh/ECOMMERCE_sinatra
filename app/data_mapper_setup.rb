env = ENV["RACK_ENV"] || "development"

DataMapper.setup(:default, "postgres://localhost/eastjam_#{env}")

DataMapper.finalize