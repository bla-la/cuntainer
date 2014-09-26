require 'yaml'
require 'fileutils'


module BDSL
  class Configuration
    puts 'Read configuraton...'
    def readConfig(path)
      begin
        cfg = YAML.load_file(path)
        @install_dir = cfg["install_dir"]
        @pkg_dir = cfg["pkg_dir"]
        @tool_dir = cfg["tool_dir"]
      rescue
        @install_dir = '/opt/app'
        @pkg_dir = '/opt/app/pkgs'
        @tool_dir = "/tools"
        puts 'Exception'
      end
      @sources_dir = "#{@install_dir}/sources" unless !@sources_dir.nil?

      @pkg_dir = File.expand_path(@pkg_dir)

    end

    def initialize(path)
      readConfig(path)
    end

    def get_install_dir
      return @install_dir
    end

    def get_tool_dir
      return @tool_dir
    end

    def get_pkg_dir
      return @pkg_dir
    end

    def info_config
      puts "Base install dir: #{get_install_dir}"
      puts "Base package dir: #{get_pkg_dir}"
      puts "Base tool dir   : #{get_tool_dir}"
    end

    def get_sources_dir
      @sources_dir
    end

    def create_source_dir
      puts "#{get_sources_dir}"
      FileUtils::mkdir_p "#{get_sources_dir}"
    end

  end
end
