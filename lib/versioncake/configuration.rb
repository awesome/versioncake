require 'active_support/core_ext/module/attribute_accessors.rb'
require 'active_support/core_ext/array/wrap.rb'

module VersionCake
  module Configuration

    SUPPORTED_VERSIONS_DEFAULT = (1..10)
    VERSION_FORMATS = [:numeric, :date]

    mattr_reader :supported_version_numbers

    mattr_accessor :extraction_strategies
    self.extraction_strategies = []

    mattr_accessor :default_version
    self.default_version = nil

    mattr_accessor :version_format
    self.version_format = :numeric

    def self.extraction_strategy=(val)
      @@extraction_strategies.clear
      Array.wrap(val).each do |configured_strategy|
        @@extraction_strategies << VersionCake::ExtractionStrategy.lookup(configured_strategy)
      end
    end

    def self.supported_version_numbers=(val)
      @@supported_version_numbers = val.respond_to?(:to_a) ? val.to_a : Array.wrap(val)
      @@supported_version_numbers.sort!.reverse!
    end

    def self.version_format=(val)
      raise Exception, "Invalid version format, acceptable values are #{VERSION_FORMATS.join(", ")}" unless VERSION_FORMATS.include?(val)
      @@version_format = val
    end

    def self.format_version(val)
      puts "formatting version number #{val} to format #{@@version_format}"
      case @@version_format
        when :numeric
          val.to_i if val && /[0-9]+/.match(val)
        when :date
          Date.strptime(val, "%Y-%m-%d") rescue nil
      end
    end

    def self.supported_versions(requested_version_number=nil)
      if requested_version_number
        versions = supported_version_numbers.dup
        versions.push(requested_version_number)
        versions.uniq!.sort!.reverse!
        version_list = versions[versions.index(requested_version_number)..versions.length]
      else
        version_list = supported_version_numbers
      end

      version_list.collect { |v| :"v#{v}" }
    end

    def self.supports_version?(version)
      puts "supports_version?(#{version}) in #{supported_version_numbers.join(",")}"
      a = supported_version_numbers.include? version
      puts "supported? #{a}"
      a
    end

    def self.latest_version
      supported_version_numbers.first
    end

    self.extraction_strategy       = :query_parameter
    self.supported_version_numbers = SUPPORTED_VERSIONS_DEFAULT
  end
end