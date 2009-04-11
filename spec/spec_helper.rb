require 'spec'

lib_path = File.join(File.dirname(__FILE__),"..","lib")
$:.unshift lib_path unless $:.include?(lib_path)

require "ruby_pbuilder"

include RubyPbuilder
