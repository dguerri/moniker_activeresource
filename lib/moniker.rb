# This file is part of the Moniker-ActiveResource
#
# Copyright (C) 2013 Unidata S.p.A. (Davide Guerri - davide.guerri@gmail.com)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'rubygems'
require 'bundler'

libdir = File.dirname(__FILE__)
Dir.chdir libdir do
  Bundler.setup
end
Bundler.require :default

open_stack_path = File.expand_path('..', __FILE__)
$:.unshift(open_stack_path) if File.directory?(open_stack_path) && !$:.include?(open_stack_path)

# Load locales for countries from +locale+ directory
I18n.load_path += Dir[ File.join(File.dirname(__FILE__), 'locale', '*.{rb,yml}') ]

module Moniker
  extend ActiveSupport::Autoload

  load 'hot_fixes.rb'

  autoload :Base
  autoload :Common
  autoload :Server
  autoload :Domain
  autoload :Record
end