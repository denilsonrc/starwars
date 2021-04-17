class Person < ApplicationRecord
    belongs_to :planet
    has_and_belongs_to_many :films
    has_and_belongs_to_many :species
    has_and_belongs_to_many :vehicles

    def specie_name
        if !self.species.first.nil?
            return "Sou um " + self.species.first.name
        else
            return "Eu não conheço minha especie"
        end
    end

    def planet_name
        if !self.planet.nil?
            return "eu nasci em " + self.planet.name
        else
            return "não sei onde nasci"
        end
    end
    def vehicle_name
        if !self.vehicles.empty?
            return "Eu já pilotei " + self.vehicles.map{|v| v.name}.join(" ,")
        else
            return "Eu nunca pilotei"
        end
    end
end
