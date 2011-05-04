#---[ Libraries ]-------------------------------------------------------

# Standard library
require "benchmark"

# Gems
require "rubygems"
require "bundler"
Bundler.require # See `Gemfile` for list of specific libraries loaded

#---[ Settings ]--------------------------------------------------------

# Settings loaded from configuration files.
class Settings < Settingslogic
  source "settings.yml" # Try this first
  source "settings~defaults.yml" # Fallback to these defaults
end

#---[ App ]-------------------------------------------------------------

# Sinatra web application.
class App < Sinatra::Base
  # Load the Synchrony stack.
  register Sinatra::Synchrony
  # Use Rack's cookies, they've been patched to work asynchronously.
  use Rack::Session::Cookie, :secret => Settings.cookie.secret
  # Render templates at the bottom of this file, past the `__END__` section.
  enable :inline_templates

  # Return a database connection pool handle. Instantiate if needed.
  def db
    # FIXME Is this a reasonable way to store the pool? I can't set it up in #configure because the event loop isn't running yet.
    @@db ||=
      db = EventMachine::Synchrony::ConnectionPool.new(size: Settings.database.pool_size) do
        EventMachine::MySQL.new(Settings.database.credentials)
      end
    return @@db
  end

  get "/" do
    haml :index
  end

  get "/sequential" do
    @title = "Sequential calls"

    @number_of_calls = 2
    @sleep_time = 0.23
    @expected_time = @number_of_calls * @sleep_time

    @description = "This action demonstrates sequential calls. It just ran #{@number_of_calls} slow database calls in sequence that each took #{@sleep_time}. The elapsed time should be about the same as the expected time, demonstrating that the slow database calls were done in sequence:"

    @elapsed_time = Benchmark.realtime {
      db.query("select sleep(#{@sleep_time})")
      db.query("select sleep(#{@sleep_time})")
    }
    @names = db.query("show databases").all_hashes.map { |row| row["Database"] }

    haml :page
  end

  get "/parallel" do
    # FIXME This method can only be called once, and will then hang and crash the server :
=begin
/home/igal/.rvm/gems/ruby-1.9.2-p180/gems/rack-fiber_pool-0.9.1/lib/fiber_pool.rb:48:in `block (3 levels) in initialize': undefined method `call' for #<EventMachine::Synchrony::Multi:0x979e3a8> (NoMethodError)
        from /home/igal/.rvm/gems/ruby-1.9.2-p180/gems/rack-fiber_pool-0.9.1/lib/fiber_pool.rb:47:in `loop'
        from /home/igal/.rvm/gems/ruby-1.9.2-p180/gems/rack-fiber_pool-0.9.1/lib/fiber_pool.rb:47:in `block (2 levels) in initialize'
=end
    
    @title = "Parallel calls"

    @number_of_calls = 4
    @sleep_time = 0.42
    @expected_time = @sleep_time

    @description = "This action demonstrates parallel calls. It just ran #{@number_of_calls} slow database calls that each took #{@sleep_time} seconds to run. The elapsed time should be about the same as the expected time, demonstrating that the slow database calls were done in parallel:"

    @elapsed_time = Benchmark.realtime do
      multi = EventMachine::Synchrony::Multi.new
      # Make one call for each connection in the database pool:
      for i in 1..Settings.database.pool_size.to_i
        multi.add(:"s#{i}", db.aquery("select sleep(#{@sleep_time})"))
      end
      multi.add(:database_names, db.aquery("show databases"))
      if result = multi.perform
        # FIXME Is this really the expected way to get results from a Multi?! Yuck.
        result.responses[:callback][:database_names].callback do |query|
          @names = query.all_hashes.map { |row| row["Database"] }
        end
      else
        # FIXME What're we supposed to do when the database pool fails, which it randomly does?
        @names = [:database, :failure, :wtf]
      end
    end

    haml :page
  end
end

__END__

@@ layout
%html
  %h1
    sinatra-synchrony
    - if @title
      \:
      = @title
  %p
    Menu:
    %a{:href => url("/")} Home
    |
    %a{:href => url("/sequential")} Sequential
    |
    %a{:href => url("/parallel")} Parallel
  %div= yield

@@ index
%p This is a sample application demonstrating sinatra-synchrony. Click on the menu items to try out its behavior.

@@ page
%h2 Timing
%p= @description
%ul
  %li
    Expected time:
    = @expected_time
    seconds
  %li
    Elapsed time:
    = @elapsed_time
    seconds
%h2 Databases
%ul
  - for name in @names
    %li= name
