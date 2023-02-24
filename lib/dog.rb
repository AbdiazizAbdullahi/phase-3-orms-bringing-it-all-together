class Dog
    attr_accessor :id, :name, :breed
  
    def initialize(id: nil, name:, breed:)
      @id = id
      @name = name
      @breed = breed
    end
  
    def self.create_table
      sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
        )
      SQL
      DB[:conn].execute(sql)
    end
  
    def self.drop_table
      sql = "DROP TABLE IF EXISTS dogs"
      DB[:conn].execute(sql)
    end
  
    def save
      if self.id
        self.update
      else
        sql = <<-SQL
          INSERT INTO dogs (name, breed)
          VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      end
      self
    end
  
    def update
      sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ? WHERE id = ?
      SQL
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
  
    def self.create(attributes)
      dog = self.new(attributes)
      dog.save
    end
  
    def self.new_from_db(row)
      self.new(id: row[0], name: row[1], breed: row[2])
    end
  
    def self.find_by_name(name)
      sql = "SELECT * FROM dogs WHERE name = ?"
      row = DB[:conn].execute(sql, name)[0]
      self.new_from_db(row)
    end
  
    def self.find(id)
      sql = "SELECT * FROM dogs WHERE id = ?"
      row = DB[:conn].execute(sql, id)[0]
      self.new_from_db(row)
    end
  
    def self.all
      sql = "SELECT * FROM dogs"
      rows = DB[:conn].execute(sql)
      rows.map { |row| self.new_from_db(row) }
    end
  
    def self.find_or_create_by(name:, breed:)
      sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
      row = DB[:conn].execute(sql, name, breed)[0]
      if row
        self.new_from_db(row)
      else
        self.create(name: name, breed: breed)
      end
    end
  end
  