sinatra-synchrony sample application
====================================

This is a small application demonstrating Kyle Drake's [sinatra-synchrony](https://github.com/kyledrake/sinatra-synchrony) stack.

Running the application
-----------------------

1. Install Ruby 1.9.2, MySQL and the MySQL headers.
2. Install Bundler:

        gem install bundler
3. Install the application's dependencies:

        bundle install
4. Copy `settings~defaults.yml` to `settings.yml` and customize it with your database credentials and such.
5. Start the application:

        thin start
6. Access the application with your web browser: http://localhost:3000/

License
-------

This code provided under the MIT License, see `LICENSE.txt` for details.
