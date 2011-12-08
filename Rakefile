require 'XCodeDeployer'
require 'XCodeProduct'

name = "HTTPServe"
products = [XCodeProduct.new(name, name, "Release", ["macosx"])]
builder = XCodeDeployer.new(products)

task :setup do
	builder.setup
end

task :default => [:build, :deploy] do
end

task :clean do
	puts "cleaning " + name
	builder.clean
end

task :build do
	puts "building " + name
	builder.build
end

task :deploy do
	puts "Deploying " + name
	builder.deploy
end

task :release => [:setup, :clean, :build, :deploy] do
	builder.release
end

