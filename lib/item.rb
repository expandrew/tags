require './lib/shared.rb'

class Item < Shared
  
  attr_accessor :table, :name, :id, :tags

  def initialize attributes
    @table = 'items'
    @name = attributes[:name]
    @id = attributes[:id]
    @opposite = 'tags'
  end

  def assign_to tag
    DB.exec("INSERT INTO items_tags (item_id, tag_id) VALUES (#{self.id}, #{tag.id});")
  end

  def list_tags
    tags = []
    from_db = DB.exec("SELECT tags.name FROM tags JOIN items_tags ON tags.id = items_tags.tag_id WHERE items_tags.item_id = #{self.id}")
    from_db.each do |tag|
      tags << tag['name']
    end
    tags
  end

  def tags
    found = []
    tags = DB.exec("SELECT * FROM items_tags WHERE item_id = '#{@id}';")
    tags.each do |tag|
      tag_id = tag['tag_id']
      matches_in_tag_table = DB.exec("SELECT * FROM tags WHERE id = '#{tag_id}'")
      matches_in_tag_table.each do |match|
        name = match["name"]
        id = match["id"].to_i
        found << Tag.new({name: name, id: id})
      end
    end
    found
  end

end