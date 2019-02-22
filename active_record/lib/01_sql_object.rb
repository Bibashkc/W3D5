require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  def self.columns
  return @columns unless @columns.nil?
  @columns = DBConnection.execute2(<<-SQL)
  SELECT *
  FROM #{self.table_name}
    SQL
   @columns = @columns.first.map{|col_name| col_name.to_sym }
  end

  def self.finalize!
   self.columns.each do |col_name|
      define_method(col_name) do
        self.attributes[col_name]
      end
      define_method(col_name.to_s+"=") do |value|
        self.attributes[col_name] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
   @table_name||=self.to_s.tableize
  end

  def self.all
   hash = DBConnection.execute2(<<-SQL)
      SELECT *
      FROM #{self.table_name}
    SQL
    self.parse_all(hash[1..-1])
  end

  def self.parse_all(results)
    results.map do |hash|
      self.new(hash)
    end
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL,id)
    SELECT *
    FROM #{self.table_name}
    WHERE id = ?
    SQL
    return nil unless result.length > 0
    self.new(result[-1])
  end

  def initialize(params = {})
    params.each do |k,v|
      raise "unknown attribute 'favorite_band'" unless self.class.columns.include?(k.to_sym)
      self.send("#{k}=",v)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values

  end

  def insert

  end

  def update

  end

  def save

  end
end
