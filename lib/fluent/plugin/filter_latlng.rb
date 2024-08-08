#
# Copyright 2024- TODO: Write your name
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'fluent/plugin/filter'
require 'geocoder'

module Fluent
  module Plugin
    class LatlngFilter < Fluent::Plugin::Filter
      Fluent::Plugin.register_filter('latlng', self)

      helpers :record_accessor

      desc 'The field to read the coordinates and update (in jsonpath like syntax)'
      config_param :coordinates, :string, default: '$.address.coordinates'

      desc 'The lookup method name to use'
      config_param :lookup, :string, default: 'esri'

      desc 'The API key to use'
      config_param :api_key, :string, default: nil, secret: true

      def initialize
        super

        Geocoder.configure(
          :lookup => :"#{@lookup}",
          :api_key => @api_key,
        )

        @coordinates_accessor = record_accessor_create(@coordinates)
      end

      def filter(tag, time, record)
        record = add_country_code(record)
        record
      end

      def add_country_code(record)
        coordinates = @coordinates_accessor.call(record)
        return record if coordinates.nil?

        result = Geocoder.search([coordinates['lat'], coordinates['lng']]).first
        log.trace "Answer: #{result.inspect}"

        # Add to coordinates hash
        coordinates['decoded'] = {
          'type' => result.place_type,
          'country' => result.country,
          'state' => result.state,
          'city' => result.city,
          'place_name' => result.place_name,
        }
        log.debug "Updated coordinates: #{coordinates}"

        # Update the record with the new coordinates
        @coordinates_accessor.set(record, coordinates)

        return record
      end

    end
  end
end
