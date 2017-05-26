# frozen_string_literal: true

require 'byebug'
require 'minitest/autorun'
require 'pp'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'objective'
