class Person < ApplicationRecord
    belongs_to :planet
    has_and_belongs_to_many :films
    has_and_belongs_to_many :species
    has_and_belongs_to_many :vehicles
end
