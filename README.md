# Using Clojure from JRuby

## Purpose

Provides a way to call Clojure from JRuby. This makes it easy to...
a) integrate your Clojure code into a JRuby project (e.g. Rails app) and
b) use fancy Clojure stuff like persistent data structures, lazy sequences etc.

## How it works

Clojure provides a Java interface to its runtime through the class clojure.lang.RT. clj.rb provides a set of
convenience methods to use this interface. The Clojure code is expected to be provided as JAR files. clj.rb 'require's
all JARs in folder 'deps'. Adapt this to your own project as needed.

clj.rb contains a single class (Clj) which...
a) provides a set of class methods to conveniently access Clojure vars, create Clojure functions from blocks etc. and
b) can be instantiated to easily call functions from a given Clojure namespace.

Be aware that this is all experimental and should not be used in production unless you know exactly what you're doing :-)

## Calling a simple function from clojure.core

Simply instantiate Clj and pass in the desired namespace (which must exist in a 'require'd JAR!). You can then
call functions like so:

	core = Clj.new "clojure.core"
	core.inc 1
	=> 2

Substitute hyphens (e.g. "my-func") with underscores (e.g. "my_func").

## Turning a ruby block into a clojure function

Pass an arbitrary block to the class function Clj.fn:

	tracing_inc = Clj.fn do |x|
	  puts "processing #{x}"
	  x + 1
	end

This creates a Clojure function which you can then pass into another Clojure function, e.g. map:

	core = Clj.new "clojure.core"
	result = core.map(tracing_inc, [1,2,3,4,5,6])

The difference to using Ruby's map/collect is that the Clojure version returns a lazy sequence. The above code does not
actually perform any processing of the given vector until 'result' is consumed.

	result.first
	=> 2

This will process the first element of [1,2,3,4,5,6] and return 2.

## Running the example

If you've JRuby set up (jruby/bin added to PATH and JAVA_HOME set) just run the script 'example.rb':

	jruby example.rb