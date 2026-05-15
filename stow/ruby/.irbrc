# ------------------------------------------------------------------------------------------------ #
# Config file for irb (interactive ruby).
# ------------------------------------------------------------------------------------------------ #
# Note:
# irb is used by rails console, so things in here will show up there. But be careful to check for a
# rails environment for rails-specific additions in here, and possibly vice versa.
#
# Also note that rbenv-installed rubies are built against the readline line editing library, whereas
# MacOS system-installed ruby is built against MacOS's own libedit (aka editline). This means that
# irb's line editing function can vary from one to the other, and you have to have the right config
# file set up: ~/.inputrc for readline vs. ~/.editrc for libedit.
# ------------------------------------------------------------------------------------------------ #

require 'irb/completion'
require 'pp'

# Start with a quiet log level.
if Object.const_defined?(:ActiveRecord)
  ActiveRecord::Base.logger.level = 1
end

# ------------------------------------------------------------------------------------------------ #
# Add convenience methods to Object so we can just type the method name in IRB.
class Object
  ANSI_BOLD       = "\033[1m"
  ANSI_RESET      = "\033[0m"
  ANSI_LGRAY    = "\033[0;37m"
  ANSI_GRAY     = "\033[1;30m"


  # ----------------------------------------------------------------------------
  # Print object's methods
  def pm(*options)
    methods = self.methods
    methods -= Object.methods unless options.include? :more
    filter = options.select {|opt| opt.kind_of? Regexp}.first
    methods = methods.select {|name| name =~ filter} if filter

    data = methods.sort.collect do |name|
      method = self.method(name)
      if method.arity == 0
        args = "()"
      elsif method.arity > 0
        n = method.arity
        args = "(#{(1..n).collect {|i| "arg#{i}"}.join(", ")})"
      elsif method.arity < 0
        n = -method.arity
        args = "(#{(1..n).collect {|i| "arg#{i}"}.join(", ")}, ...)"
      end
      klass = $1 if method.inspect =~ /Method: (.*?)#/
      [name, args, klass]
    end
    max_name = data.collect {|item| item[0].size}.max
    max_args = data.collect {|item| item[1].size}.max
    data.each do |item|
      print " #{ANSI_BOLD}#{item[0].rjust(max_name)}#{ANSI_RESET}"
      print "#{ANSI_GRAY}#{item[1].ljust(max_args)}#{ANSI_RESET}"
      print "   #{ANSI_LGRAY}#{item[2]}#{ANSI_RESET}\n"
    end
    data.size
  end


  # ----------------------------------------------------------------------------
  # Some quick data structures to always have on hand. Pass true for reset to
  # bring them back to their original contents.
  def a1(reset=false)
    @a1 = %w[a b c d e f] if @a1.nil? || reset
    @a1
  end

  def a2(reset=false)
    @a2 = %w[x y z] if @a2.nil? || reset
    @a2
  end

  def h1(reset=false)
    if @h1.nil? || reset
      @h1 = {:a => "aaa", :b => "bbb", :c => "ccc",
             :d => "ddd", :e => "eee", :f => "fff"}
    end
    @h1
  end

  def h2(reset=false)
    @h2 = {:x => "xxx", :y => "yyy", :z => "zzz"} if @h2.nil? || reset
    @h2
  end


  # ----------------------------------------------------------------------------
  # Various convenience methods applicable to both irb and the Rails console.

  # Hit quick "s" for some vertical space.
  def s(retval = nil)
    1.times { puts }
    retval
  end


  # ----------------------------------------------------------------------------
  # Rails-specifc convenience methods.

  # rl for reloading rails files from the rails console. Currently doesn't work
  # in stock irb, but should probably make an irb-specific reload! method to do
  # that. There could be a method called by default in irbrc that stores a -r
  # library in a "loaded files" array, and a custom load method that adds any
  # loaded during run to the same array, and then reload! or rl could check if
  # we're in a rails console or not and call the appropriate method.
  def rl
    reload!
    s(true)
  end

  # Since I always forget how to get to recognize_path from the Rails object.
  def recognize_path(path)
    Rails.application.routes.recognize_path(path)
  end

  # Quickly set the Rails log level. Useful to hide/show SQL statements and the
  # like as desired.
  def log_level(level = nil)
    if level
      cmd = "ActiveRecord::Base.logger.level = #{level}"
      puts cmd
      eval cmd
    else
      level = ActiveRecord::Base.logger.level
      puts "ActiveRecord::Base.logger.level: #{level}"
      level
    end
  end

  # Quickly set the Rails log level to be quiet or verbose.
  def ql
    log_level(1)
  end
  def vl
    log_level(0)
  end

  # Quickly set $quiet_inspect to true or false.
  def qi
    $quiet_inspect = true
  end
  def vi
    $quiet_inspect = false
  end


  # ----------------------------------------------------------------------------
  # For apps with a Company.current and a CompanyInformation.time_zone, quickly
  # set the current company.
  def set_company(company_id)
    Company.current = Company.find(company_id)
    Time.zone = CompanyInformation.time_zone
  end
end


# ------------------------------------------------------------------------------------------------ #
# Shorter .inspect output for verbose classes. The .inspect of instance objects will frequently
# include attributes and values in the output, and it's sometimes too much to look at. Here we make
# a quiet version of the method for Object itself and for any sub-classes with their own overridden
# versions that are also verbose. Enable the quiet versions with the global variable $quiet_inspect.
# Even when enabled, the original inspect method can be called with the shortcut method .oi.

class Object
  alias_method(:orig_inspect, :inspect)
  def inspect
    $quiet_inspect ? "#<#{self.class}:0x#{self.object_id.to_s(16)}>" : orig_inspect
  end
  def oi
    puts orig_inspect
  end
end

if Object.const_defined?(:ActiveRecord)
  class ActiveRecord::Base
    alias_method(:orig_inspect, :inspect)
    def inspect
      $quiet_inspect ? "#<#{self.class}:#{self.id || 'new'}>" : orig_inspect
    end
    def oi
      puts orig_inspect
    end
  end
end


# ------------------------------------------------------------------------------------------------ #
# irb config that always gets set up if conditions match.

# Prevent the warning about aliasing context from irb_context.
if Object.const_defined?(:RSpec)
  RSpec.configure do |config|
    config.disable_monkey_patching!
  end
end

# Store IRB history for future sessions.
if IRB.singleton_methods.include?(:conf)
  begin
    # For older Ruby versions (< 3.0), we need the classic `save-history` extension.
    require 'irb/ext/save-history' if RUBY_VERSION < '3.0.0'
    IRB.conf[:SAVE_HISTORY] = 1000
    IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"
  rescue LoadError
    warn "=> Could not load 'irb/ext/save-history'. History will not be saved for this session."
  end
end

# Extra setup for Rails consoles.
if $0.include?("rails")
  # Log to STDOUT.
  if !Object.const_defined?('RAILS_DEFAULT_LOGGER')
    require 'logger'
    RAILS_DEFAULT_LOGGER = Logger.new(STDOUT)
  end
end
