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

module Moniker

  # A Moniker Server
  #
  # ==== Attributes
  # * +name+ - Name of this image
  # * +updated_at+ - Modification date
  # * +created_at+ - Creation date
  class Server < Common
    schema do
      attribute :name, :string
      attribute :updated_at, :datetime
      attribute :created_at, :datetime
    end

    validates :name,
              :presence => true,
              :format => {:with => /\A[\w\.\-\_]{2,}\Z/, :allow_blank => true},
              :length => {:maximum => 255}

    def initialize(attributes = {}, persisted = false) # :notnew:
      attributes = attributes.with_indifferent_access
      new_attributes = {
          :id => attributes[:id],
          :name => attributes[:name],
          :updated_at => attributes[:created_at].present? ? DateTime.strptime(attributes[:created_at], Moniker::DATETIME_FORMAT) : nil,
          :created_at => attributes[:created_at].present? ? DateTime.strptime(attributes[:created_at], Moniker::DATETIME_FORMAT) : nil
      }

      super(new_attributes, persisted)
    end

    # Overloads ActiveRecord::encode method
    def encode(options={}) # :nodoc: Custom encoding to deal with moniker API
      to_encode = {
          :name => name
      }

      to_encode.send("to_#{self.class.format.extension}", options)
    end

    def self.find_by_name(name, options = {})
      all(options).detect { |domain| domain.name == name }
    end

  end

end
