require 'rubygems'
require 'bundler'
Bundler.require

$LOAD_PATH.unshift ::File.expand_path(::File.dirname(__FILE__) + '/lib')
require 'bad_browser'

run BadBrowser