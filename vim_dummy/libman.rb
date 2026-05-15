#!/usr/bin/env ruby
# frozen_string_literal: true

# A simple library management system demonstrating Ruby classes,
# methods, instantiation, and formatting standards.

# Constants are written in UPPER_SNAKE_CASE
MAX_BOOKS_PER_USER = 5
LATE_FEE_PER_DAY = 0.50

# Base class for Library Items
class LibraryItem
  attr_reader :id, :title, :is_checked_out

  def initialize(id, title)
    @id = id
    @title = title
    @is_checked_out = false
    @checkout_date = nil
    @due_date = nil
  end

  def check_out(user_id)
    if @is_checked_out
      puts "Error: '#{title}' is already checked out."
      return false
    end

    @is_checked_out = true
    @user_id = user_id
    @checkout_date = Date.today
    @due_date = @checkout_date + 14 # Two weeks loan period
    puts "Checked out '#{title}' to user #{user_id}."
    true
  end

  def return_item
    unless @is_checked_out
      puts "Error: '#{title}' was not checked out."
      return false
    end

    @is_checked_out = false
    @user_id = nil
    @checkout_date = nil
    @due_date = nil
    puts "Returned '#{title}'."
    true
  end

  def days_overdue
    return 0 unless @is_checked_out

    today = Date.today
    if today > @due_date
      (today - @due_date).to_i
    else
      0
    end
  end

  def late_fee
    overdue_days = days_overdue
    overdue_days > 0 ? overdue_days * LATE_FEE_PER_DAY : 0.0
  end

  def to_s
    status = @is_checked_out ? "Checked Out" : "Available"
    "#<LibraryItem id=#{@id} title='#{@title}' status=#{status}>"
  end
end

# Subclass for Books
class Book < LibraryItem
  attr_reader :author, :isbn

  def initialize(id, title, author, isbn)
    super(id, title)
    @author = author
    @isbn = isbn
  end

  def to_s
    base = super
    "#{base} (Author: #{@author}, ISBN: #{@isbn})"
  end
end

# Subclass for Magazines
class Magazine < LibraryItem
  attr_reader :issue_number, :publication_date

  def initialize(id, title, issue_number, publication_date)
    super(id, title)
    @issue_number = issue_number
    @publication_date = publication_date
  end

  def to_s
    base = super
    "#{base} (Issue: #{@issue_number}, Date: #{@publication_date})"
  end
end

# User class
class LibraryUser
  attr_reader :id, :name, :checked_out_items

  def initialize(id, name)
    @id = id
    @name = name
    @checked_out_items = []
  end

  def can_checkout?(item)
    if @checked_out_items.size >= MAX_BOOKS_PER_USER
      puts "Error: User #{@name} has reached the maximum checkout limit."
      return false
    end

    if item.is_checked_out
      puts "Error: Item '#{item.title}' is already checked out."
      return false
    end

    true
  end

  def checkout_item(item)
    if can_checkout?(item)
      item.check_out(@id)
      @checked_out_items << item
      true
    else
      false
    end
  end

  def return_item(item)
    if @checked_out_items.include?(item)
      item.return_item
      @checked_out_items.delete(item)
      fee = item.late_fee
      if fee > 0
        puts "Late fee for #{@name}: $#{fee.toFixed(2)}"
      end
      true
    else
      puts "Error: User #{@name} does not have '#{item.title}' checked out."
      false
    end
  end

  def summary
    puts "User: #{@name} (ID: #{@id})"
    puts "Items Checked Out: #{@checked_out_items.size} / #{MAX_BOOKS_PER_USER}"
    @checked_out_items.each do |item|
      puts "  - #{item.title} (Due: #{item.instance_variable_get(:@due_date)})"
    end
  end
end

# Library Manager class
class LibraryManager
  def initialize
    @items = []
    @users = {}
  end

  def add_item(item)
    @items << item
    puts "Added item: #{item.title}"
  end

  def get_item_by_id(id)
    @items.find { |item| item.id == id }
  end

  def get_user_by_id(id)
    @users[id]
  end

  def register_user(id, name)
    if @users[id]
      puts "User ID #{id} already exists."
      return false
    end

    @users[id] = LibraryUser.new(id, name)
    puts "Registered user: #{name}"
    true
  end

  def process_checkout(user_id, item_id)
    user = get_user_by_id(user_id)
    item = get_item_by_id(item_id)

    unless user
      puts "Error: User ID #{user_id} not found."
      return
    end

    unless item
      puts "Error: Item ID #{item_id} not found."
      return
    end

    user.checkout_item(item)
  end

  def process_return(user_id, item_id)
    user = get_user_by_id(user_id)
    item = get_item_by_id(item_id)

    unless user
      puts "Error: User ID #{user_id} not found."
      return
    end

    unless item
      puts "Error: Item ID #{item_id} not found."
      return
    end

    user.return_item(item)
  end

  def list_all_items
    puts "\n--- All Library Items ---"
    @items.each do |item|
      puts item.to_s
    end
    puts "-------------------------\n"
  end

  def list_all_users
    puts "\n--- All Registered Users ---"
    @users.values.each do |user|
      user.summary
    end
    puts "----------------------------\n"
  end
end

# Main execution block
if __FILE__ == $PROGRAM_NAME
  manager = LibraryManager.new

  # Register users
  manager.register_user(1, "Alice Smith")
  manager.register_user(2, "Bob Jones")

  # Add items
  book1 = Book.new(101, "The Ruby Way", "Hal Fulton", "978-0321498558")
  book2 = Book.new(102, "Clean Code", "Robert C. Martin", "978-0132350884")
  mag1 = Magazine.new(201, "Tech Monthly", 45, "2026-05-01")

  manager.add_item(book1)
  manager.add_item(book2)
  manager.add_item(mag1)

  # List all items
  manager.list_all_items

  # Checkout process
  manager.process_checkout(1, 101) # Alice checks out Book 1
  manager.process_checkout(1, 102) # Alice checks out Book 2
  manager.process_checkout(2, 201) # Bob checks out Magazine 1

  # List users to see status
  manager.list_all_users

  # Return process
  manager.process_return(1, 101) # Alice returns Book 1

  # Final status
  manager.list_all_users
end
