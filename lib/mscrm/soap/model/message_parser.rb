require 'ostruct'
require 'rexml/document'

module Mscrm
  module Soap
    module Model

      module MessageParser

        def self.parse_key_value_pairs(parent_element)
          h = {}
          # Get namespace alias (letter) for child elements.
          namespace_alias = parent_element.attributes.keys.first
          parent_element.each_element do |key_value_pair|

            key_element = key_value_pair.elements["#{namespace_alias}:key"]
            key = key_element.text
            value_element = key_value_pair.elements["#{namespace_alias}:value"]
            value = value_element.text

            begin

              case value_element.attributes["type"]
              when "b:OptionSetValue"
                # Nested value. Appears to always be an integer.
                value = value_element.elements.first.text.to_i
              when "d:boolean"
                value = (value == "true")
              when "d:decimal"
                value = value.to_f
              when "d:dateTime"
                value = Time.parse(value)
              when "b:EntityReference"
                entity_ref = {}
                value_element.each_element do |child|
                  entity_ref[child.name] = child.text
                end
                value = entity_ref
              when "d:EntityMetadata", /^d:\w*AttributeMetadata$/
                value = value_element
              when "d:ArrayOfEntityMetadata"
                value = value_element.get_elements("d:EntityMetadata")
              when "d:ArrayOfAttributeMetadata"
                value = value_element.get_elements("d:AttributeMetadata")
              when "b:Money"
                # Nested value.
                value = value_element.elements.first.text.to_f
              when "d:int"
                value = value.to_i
              when "d:string", "d:guid"
                # nothing
              end
            rescue => e
              # In case there's an error during type conversion.
              puts e.message
            end

            h[key] = value
          end
          h
        end

      end

    end
  end
end
