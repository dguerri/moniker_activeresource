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

  # A Moniker Domain
  #
  # ==== Attributes
  # * +name+ - Name of this image
  # * +email+ - e-mail of the registrant
  # * +ttl+ - domain ttl
  # * +serial+ - domain serial
  # * +updated_at+ - Modification date
  # * +created_at+ - Creation date
  class Domain < Common
    schema do
      attribute :name, :string
      attribute :email, :string
      attribute :ttl, :integer
      attribute :serial, :integer
      attribute :updated_at, :datetime
      attribute :created_at, :datetime
    end

    validates :name,
              :presence => true,
              :format => {:with => /\A[\w\.\-\_]{2,}\Z/, :allow_blank => true},
              :length => {:maximum => 255}
    validates :ttl,
              :numericality => {:greater_than => 0, :less_than_or_equal_to => 86400, :only_integer => true, :allow_blank => true}
    validates :email,
              :presence => true,
              :format => {:with => /\A[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}\Z/i, :allow_blank => true}

    def initialize(attributes = {}, persisted = false) # :notnew:
      attributes = attributes.with_indifferent_access
      new_attributes = {
          :id => attributes[:id],
          :name => attributes[:name],
          :email => attributes[:email],
          :ttl => attributes[:ttl].present? ? attributes[:ttl].to_i : nil,
          :serial => attributes[:serial].present? ? attributes[:serial] : nil,
          :updated_at => attributes[:updated].present? ? DateTime.strptime(attributes[:updated], Moniker::DATETIME_FORMAT) : nil,
          :created_at => attributes[:created].present? ? DateTime.strptime(attributes[:created], Moniker::DATETIME_FORMAT) : nil
      }

      super(new_attributes, persisted)
    end

    # Overloads ActiveRecord::encode method
    def encode(options={}) # :nodoc: Custom encoding to deal with moniker API
      to_encode = {
          :name => name,
          :email => email,
      }

      to_encode[:ttl] = ttl if ttl.present?
      to_encode[:serial] = serial if serial.present?

      to_encode.send("to_#{self.class.format.extension}", options)
    end

    def records
      persisted? ? Record.find(:all, :domain_id => id) : []
    end

    def self.find_by_name(name, options = {})
      all(options).detect { |domain| domain.name == name }
    end

    def self.find_all_by_email(email, options = {})
      all(options).select { |domain| domain.email == email }
    end

  end

end
