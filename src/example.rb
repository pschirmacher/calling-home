require "#{File.dirname(__FILE__)}/clj.rb"

# calling a simple function from clojure.core
core = Clj.new "clojure.core"
puts "(inc 1) => #{core.inc 1}"

# turning a ruby block into a clojure function
tracing_inc = Clj.fn do |x|
  puts "processing #{x}"
  x + 1
end

# mapping the clojure function over a ruby vector (returns a lazy sequence)
result = core.map(tracing_inc, [1,2,3,4,5,6])

# only the first item is processed
puts result.first

# evaluating a clojure form (persistent array map)
the_map = Clj.eval "{:one 1 :two 2}"
one_key = Clj.keyword "one"
puts "one => #{the_map[one_key]}"