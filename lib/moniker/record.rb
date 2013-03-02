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
  class Record < Common
    self.site = "#{self.superclass.site}/domains/:domain_id"

    schema do
      attribute :name, :string
      attribute :type, :string
      attribute :ttl, :integer
      attribute :priority, :integer
      attribute :data, :string
      attribute :domain_id, :string
      attribute :updated_at, :datetime
      attribute :created_at, :datetime
    end

    validates :name,
              :presence => true,
              :format => {:with => /\A[\w\.\-\_]{2,}\Z/, :allow_blank => true},
              :length => {:maximum => 255}
    validates :type,
              :presence => true,
              :inclusion => {:in => %w(A AAAA CNAME MX SRV TXT NS PTR)}
    validates :data,
              :presence => true,
              :length => {:maximum => 255}
    validates :ttl,
              :numericality => {:greater_than => 0, :less_than_or_equal_to => 86400, :only_integer => true, :allow_blank => true}
    validates :priority,
              :numericality => {:greater_than => 0, :less_than_or_equal_to => 255, :only_integer => true, :allow_blank => true}


    def initialize(attributes = {}, persisted = false) # :notnew:
      attributes = attributes.with_indifferent_access
      new_attributes = {
          :id => attributes[:id],
          :name => attributes[:name],
          :type => attributes[:type],
          :domain_id => attributes[:domain_id],
          :ttl => attributes[:ttl].present? ? attributes[:ttl].to_i : nil,
          :priority => attributes[:priority].present? ? attributes[:priority].to_i : nil,
          :data => attributes[:data],
          :updated_at => attributes[:created_at].present? ? DateTime.strptime(attributes[:created_at], Moniker::DATETIME_FORMAT) : nil,
          :created_at => attributes[:created_at].present? ? DateTime.strptime(attributes[:created_at], Moniker::DATETIME_FORMAT) : nil
      }

      super(new_attributes, persisted)
    end

    # Overloads ActiveRecord::encode method
    # @param [Object] options
    def encode(options={}) # :nodoc: Custom encoding to deal with moniker API
      to_encode = {
          :name => name,
          :type => type,
          :data => data
      }

      to_encode[:ttl] = ttl if ttl.present?
      to_encode[:priority] = priority if priority.present?

      to_encode.send("to_#{self.class.format.extension}", options)
    end

    def update_attributes(attributes)
      super attributes.merge @prefix_options
    end

    def domain_id
      @prefix_options[:domain_id]
    end

    def domain
      domain_id.present? ? (Domain.find domain_id) : nil
    rescue ActiveResource::ResourceNotFound => e

      nil
    end

    def self.find_by_name(name, options = {})
      all(options).detect { |record| record.name == name }
    end

    def self.find_all_by_name(name, options = {})
      all(options).select { |record| record.name == name }
    end

    def self.find_all_by_type(type, options = {})
      all(options).select { |record| record.type == type }
    end

    def self.find_all_by_data(data, options = {})
      all(options).select { |record| record.data == data }
    end

  end

end
