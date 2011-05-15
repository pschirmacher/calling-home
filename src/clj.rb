require "java"
Dir["#{File.dirname(__FILE__)}/../deps/*.jar"].each do |jar|
  require jar
end

class Clj
  def self.fn(&block)
    clj_fn = Java::clojure.lang.IFn.new
    # see http://stackoverflow.com/questions/2495550/define-a-method-that-is-a-closure-in-ruby/2495650#2495650
    singleton_class = class << clj_fn; self; end
    singleton_class.send(:define_method, :invoke) do |*args|
      block.call(*args)
    end
    clj_fn
  end
  
  def self.var(namespace, var)
    Java::clojure.lang.RT.var(namespace, var)
  end
  
  def self.symbol(str)
    clj_symbol = Clj.var("clojure.core", "symbol")
    clj_symbol.invoke str
  end
  
  def self.keyword(str)
    clj_keyword = Clj.var("clojure.core", "keyword")
    clj_keyword.invoke str
  end
  
  def self.eval(single_form)
    core = Clj.new "clojure.core"
    core.eval core.read_string(single_form)
  end
  
  # instance stuff
  
  def initialize(namespace)
    @namespace = namespace
    clj_require = Java::clojure.lang.RT.var("clojure.core", "require")
    clj_require.invoke Clj.symbol(namespace)
  end
  
  def method_missing(method_sym, *args)
    call_clj(method_sym.to_s, *args)
  end
  
  def respond_to?(method_sym, include_private = false)
    bound_var(method_sym.to_s) != nil
  end
  
  def bound_var(name)
    attempts = [name, name.gsub("_", "-")]
    possible_vars = attempts.collect {|attempt| Clj.var(@namespace, attempt)}
    possible_vars.detect {|v| v.isBound}
  end
  
  def call_clj(name, *args)
    v = bound_var(name)
    if v != nil
      v.invoke(*args)
    else
      raise "#{name} not bound in #{@namespace}"
    end
  end
end