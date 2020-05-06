#    Copyright 2018 Tech Bureau, Corp
# 
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
# 
#        http://www.apache.org/licenses/LICENSE-2.0
# 
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
module Catapult::Bootstrap
  class Addresses
    require_relative('addresses/parse')
    include Global

    DEFAULT_SECTION_SIZES = {
      ParseKey.peer_nodes                   => 5,
      ParseKey.api_nodes                    => 2,
      ParseKey.rest_gateways                => 2,
      ParseKey.nemesis_addresses_harvesting => 3,
      ParseKey.nemesis_generation_hash      => 1,
      ParseKey.nemesis_signer_private_key   => 1
    }

    def initialize(input_file_path, address_total)
      @input_file_path  = input_file_path
      @address_total    = address_total
    end
    
    def self.parse(input_file_path, address_total, output_form: nil)
      new(input_file_path, address_total).parse(output_form: output_form)
    end
    def parse(output_form: nil)
      Parse.parse(self.raw_address_info, self.section_sizes, break_into_sections: true, output_form: output_form)
    end

    protected

    attr_reader :input_file_path, :address_total

    def raw_address_info
      @raw_address_info ||= ::File.open(self.input_file_path).read
    end

    def section_sizes
      @section_sizes ||= ret_section_sizes
    end

    def num_harvesting_keys
      @num_harvesting_keys ||= 
        DEFAULT_SECTION_SIZES[ParseKey.nemesis_addresses_harvesting] || 
        fail("Unexpected that ParseKey.nemesis_addresses_harvesting is nil")
    end
    
    private
    
    def ret_section_sizes
      # Rules are that nemesis_addresses_harvesting_vrf has same size as nemesis_addresses_harvesting and
      # remaining addresses used in nemesis_addresses
      ret = DEFAULT_SECTION_SIZES.merge(ParseKey.nemesis_addresses_harvesting_vrf => self.num_harvesting_keys)
      num_nemesis_addresses = self.address_total - ret.values.sum
      fail "Not enough total addresses to generate nemesis addresses" if num_nemesis_addresses < 1
      ret.merge(ParseKey.nemesis_addresses => num_nemesis_addresses)
    end
  end
end
