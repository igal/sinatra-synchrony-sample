sinatra-synchrony sample application
====================================

This is a small application demonstrating Kyle Drake's [sinatra-synchrony](https://github.com/kyledrake/sinatra-synchrony) stack.

You may want to look at my [nodejs-concurrency-sample](https://github.com/igal/nodejs-concurrency-sample) application, which is the same application implemented using the [node.js](http://nodejs.org/) event-driven framework, [VisionMedia Express](http://expressjs.com/) web framework, and [Seq](https://github.com/substack/node-seq) concurrency library.

WARNING
-------

This code doesn't work correctly, and will hang and crash. My hope is that someone that knows how these libraries are intended to work can submit a pull request with corrections so I and others could submit documentation patches back to the originating projects. Or if these are bugs, please comment so we can bugs. Please see `FIXME` lines in the `app.rb` file for details.

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
