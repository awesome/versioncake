module VersionCake
  class VersionedRequest
    attr_reader :version, :extracted_version, :is_latest_version

    def initialize(request, version_override=nil)
      @version = version_override || extract_version(request)
      @is_latest_version = @version == config.latest_version
    end

    def supported_versions
      config.supported_versions(@version)
    end

    private

    def apply_strategies(request)
      version = nil
      puts config.extraction_strategies
      config.extraction_strategies.each do |strategy|
        version = strategy.extract(request)
        puts "strategy #{strategy} version: #{version.class}"
        break unless version.nil?
      end
      version ? config.format_version(version) : nil
    end

    def extract_version(request)
      @extracted_version = apply_strategies(request)
      puts "extracted version #{@extracted_version}, class #{@extracted_version.class}"
      puts "latest version: #{config.latest_version.class}"
      if @extracted_version.nil?
        puts "using default version"
        @version = config.default_version || config.latest_version
      elsif config.supports_version? @extracted_version
        puts "version is supported"
        @version = @extracted_version
      elsif @extracted_version > config.latest_version
        puts "version is too large"
        raise ActionController::RoutingError.new("No route match for version")
      else
        puts "version is deprecated"
        raise ActionController::RoutingError.new("Version is deprecated")
      end
    end

    def config
      VersionCake::Configuration
    end
  end
end