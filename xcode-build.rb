#!/usr/bin/env ruby
require 'rubygems'
require 'XCodeDeployer'

builder = XCodeDeployer.new("HTTPServe")
builder.release