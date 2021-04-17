require 'sequel'
require 'rest-client'
require 'json'

BASE_URL = 'https://swapi.dev/api/'
PLANETS = 'planets/'
PEOPLE = 'people/'
STARSHIPS = 'starships/'
VEHICLES = 'vehicles/'
SPECIES = 'species/'
FILMS = 'films/'

#criação do banco
Sequel.connect('sqlite://starwars/db/development.db'){|db|
    db.create_table :people do
        primary_key :id
        String :name
        Integer :height
        Integer :mass
        String :hair_color
        String :skin_color
        String :eye_color
        String :birth_year
        String :gender
        DateTime :created
        DateTime :edited
        String :url

        
        foreign_key :planet_id, :planets, :null=>true
    
    end

    db.create_table :species do
        primary_key :id
        String :name
        String :classification
        String :designation
        Integer :average_height
        String :skin_colors
        String :hair_colors
        String :eye_colors
        String :average_lifespan
        String :language
        DateTime :created
        DateTime :edited
        String :url


        foreign_key :planet_id, :planets, :null=>true

    end

    db.create_table :planets do
        primary_key :id
        String :name
        Integer :rotation_period
        Integer :orbital_period
        Integer :diameter
        String :climate
        String :gravity
        String :terrain
        Integer :surface_water
        Integer :population
        DateTime :created
        DateTime :edited
        String :url

    end

    db.create_table :vehicles do
        primary_key :id
        String :name
        String :model
        String :manufacturer
        Decimal :cost_in_credits
        Integer :length
        Integer :max_atmosphering_speed
        String :crew
        Integer :passengers
        Decimal :cargo_capacity
        String :consumables
        Decimal :hyperdrive_rating
        Integer :mglt
        String :starship_class
        String :vehicle_class  
        DateTime :created
        DateTime :edited
        String :url

    end

    db.create_table :films do
        primary_key :id
        String :title
        Integer :episode_id
        String :opening_crawl
        String :director
        String :producer
        Date :release_date
        DateTime :created
        DateTime :edited
        String :url

    end

    # relacionamentos de pessoas
    db.create_join_table(:person_id=>:people, :film_id=>:films)
    db.create_join_table(:person_id=>:people, :specie_id=>:species)
    db.create_join_table(:person_id=>:people, :vehicle_id=>:vehicles)

    # relacionamento de films
    db.create_join_table(:film_id=>:films, :specie_id=>:species)
    db.create_join_table(:film_id=>:films, :planet_id=>:planets)  
    db.create_join_table(:film_id=>:films, :vehicle_id=>:vehicles) 
}

#consumindo a api
def get_all(param)
    controle_api = JSON.parse(RestClient.get("#{BASE_URL}#{param}").body)
    array_resp = controle_api['results'] 
    while controle_api["next"]
        controle_api = JSON.parse(RestClient.get("#{controle_api['next']}").body)
        array_resp += controle_api['results']
    end
    return array_resp
end
#função para inserir registros de tabelas com relação de n para n
def insert_relationship(db, url, table_a, table_b, plural_a, plural_b, id)
    unless url.nil? and url.empty?
        model = db[:"#{plural_a}"][:url=>url]
        unless model.nil?
            model = model[:id] 
            db[:"#{plural_b}_#{plural_a}"].insert(:"#{table_b}_id"=>id,:"#{table_a}_id"=>model) 
        end
    end
end

starships = get_all(STARSHIPS)
people = get_all(PEOPLE)
planets = get_all(PLANETS)
vehicles = get_all(VEHICLES)
species = get_all(SPECIES)
films = get_all(FILMS)

puts "starships: #{starships.count} - people: #{people.count} - planets: #{planets.count} - vehicles: #{vehicles.count} - species: #{species.count} - films: #{films.count}"


Sequel.connect('sqlite://starwars/db/development.db'){|db|
    planets.map{|planet|
        db[:planets].insert(:name=>planet["name"], :rotation_period=>planet["rotation_period"], :orbital_period=>planet["orbital_period"], :diameter=>planet["diameter"], :climate=> planet["climate"], :gravity=>planet["gravity"], :terrain=>planet["terrain"], :surface_water=>planet["surface_water"], :population=>planet["population"], :created=>planet["created"], :edited=>planet["edited"], :url=>planet["url"])
    }
    species.map{|specie|
        planet = db[:planets][:url=>specie["homeworld"]]
        planet = planet[:id] unless planet.nil?
        db[:species].insert(:name=>specie["name"], :classification=>specie["classification"], :designation=>specie["designation"], :average_height=>specie["average_height"], :skin_colors=>specie["skin_colors"], :average_lifespan=>specie["average_lifespan"], :language=>specie["language"], :created=>specie["created"], :edited=>specie["edited"], :url=>specie["url"], :planet_id=>planet)
    }
    starships.map{|starship|
        db[:vehicles].insert(:name=>starship["name"], :model=>starship["model"], :manufacturer=>starship["manufacturer"], :cost_in_credits=>starship["cost_in_credits"], :length=>starship["length"], :max_atmosphering_speed=>starship["max_atmosphering_speed"], :crew=>starship["crew"], :passengers=>starship["passengers"], :cargo_capacity=>starship["cargo_capacity"], :consumables=>starship["consumables"], :hyperdrive_rating=>starship["hyperdrive_rating"], :mglt=>starship["mglt"], :starship_class=>starship["starship_class"], :created=>starship["created"], :edited=>starship["edited"], :url=>starship["url"])
    }
    vehicles.map{|vehicle|
        db[:vehicles].insert(:name=>vehicle["name"], :model=>vehicle["model"], :manufacturer=>vehicle["manufacturer"], :cost_in_credits=>vehicle["cost_in_credits"], :length=>vehicle["length"], :max_atmosphering_speed=>vehicle["max_atmosphering_speed"], :crew=>vehicle["crew"], :passengers=>vehicle["passengers"], :cargo_capacity=>vehicle["cargo_capacity"], :consumables=>vehicle["consumables"], :hyperdrive_rating=>vehicle["hyperdrive_rating"], :mglt=>vehicle["mglt"], :vehicle_class=>vehicle["vehicle_class"], :created=>vehicle["created"], :edited=>vehicle["edited"], :url=>vehicle["url"])
    }
    people.map{|person|
        planet = db[:planets][:url=>person["homeworld"]]
        planet = planet[:id] unless planet.nil?
        resp = db[:people].insert(:name=>person["name"], :height=>person["height"], :mass=>person["mass"], :hair_color=>person["hair_color"], :skin_color=>person["skin_color"], :eye_color=>person["eye_color"], :birth_year=>person["birth_year"], :gender=>person["gender"], :created=>person["created"], :edited=>person["edited"], :url=>person["url"], :planet_id=>planet)
        person["species"].map{|url|
            insert_relationship(db,url, "specie", "person", "species", "people", resp)
        }
        person["vehicles"].map{|url|
            insert_relationship(db,url, "vehicle", "person", "vehicles", "people", resp)
        }
        #classe starships e vehicles vindos da api compartilham a mesma tabela no banco
        person["starships"].map{|url|
            insert_relationship(db,url, "vehicle", "person", "vehicles", "people", resp)
        }
    }
    films.map{|film|
        resp = db[:films].insert(:title=>film["title"], :episode_id=>film["episode_id"], :opening_crawl=>film["opening_crawl"], :director=>film["director"], :producer=>film["producer"], :release_date=>film["release_date"], :created=>film["created"], :edited=>film["edited"], :url=>film["url"])
        film["characters"].map{|url|
            insert_relationship(db,url, "person", "film", "people", "films", resp)
        }
        film["species"].map{|url|
            insert_relationship(db,url, "specie", "film", "species", "films", resp)
        }
        film["planets"].map{|url|
            insert_relationship(db,url, "planet", "film", "planets", "films", resp)
        }
        film["starships"].map{|url|
            insert_relationship(db,url, "vehicle", "film", "vehicles", "films", resp)
        }
        #classe starships e vehicles vindos da api compartilham a mesma tabela no banco
        film["vehicles"].map{|url|
            insert_relationship(db,url, "vehicle", "film", "vehicles", "films", resp)
        }
    }
}
