require 'rubygems'
require 'active_support/core_ext/string/inflections'

require 'pg'
require 'pry'


class Shared

  def self.all
    table_name = self.to_s.downcase.pluralize
    from_db = DB.exec("SELECT * FROM #{table_name};")
    all_objects = []
    from_db.each do |object|
      name = object['name']
      id = object['id'].to_i
      new_object = self.new({:name => name, :id => id})
      all_objects << new_object
    end
    all_objects
  end

  def self.list
    table_name = self.to_s.downcase.pluralize
    from_db = DB.exec("SELECT * FROM #{table_name};")
    all_names = []
    from_db.each do |object|
      all_names << object['name']
    end
    all_names
  end

  def self.search_by_name name
    self.all.find { |object| object.name == name}
  end

  def save
    save = DB.exec("INSERT INTO #{self.table} (name) VALUES ('#{self.name}') RETURNING id;")
    @id = save.first['id'].to_i
  end

  def == another_object
    self.name == another_object.name
  end

  def rename new_name
    self.name = new_name
    DB.exec("UPDATE #{self.table} SET name = '#{new_name}' WHERE id = #{self.id};")
  end

  def remove
    DB.exec("DELETE FROM #{self.table} WHERE id = #{self.id}")
    DB.exec("DELETE FROM items_tags WHERE #{self.class}_id = #{self.id}")
  end

end