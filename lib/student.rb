require_relative "../config/environment.rb"
require 'pry'

class Student

  attr_accessor :name, :grade, :id

  def initialize (name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
          CREATE TABLE students (
            id INTEGER PRIMARY KEY,
            name TEXT,
            grade TEXT
          )
          SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
          DROP TABLE students
          SQL
    DB[:conn].execute(sql)
  end

  def save
    if !self.id.nil?
      self.update
    end
    values = [self.name, self.grade]
    sql = <<-SQL
          INSERT INTO students (name, grade)
          VALUES (?,?)
          SQL
    DB[:conn].execute(sql, values)
    self.id = DB[:conn].execute("SELECT id FROM students WHERE name = ? AND grade = ?", values)[0][0]
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
  end

  def self.new_from_db(row)
    Student.new(row[1], row[2], row[0])
    #binding.pry
  end

  def self.find_by_name(name)
    sql = <<-SQL
          SELECT * FROM students
          WHERE name = ?
          SQL
    returned_student = DB[:conn].execute(sql, [name]).flatten
    self.new_from_db(returned_student)
  end

  def update
    sql = <<-SQL
          UPDATE students
          SET name = ?, grade = ?
          WHERE id = ?
          SQL
    DB[:conn].execute(sql, [self.name, self.grade, self.id])
  end
end
