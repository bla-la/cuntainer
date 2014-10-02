require 'bdsl/config'
require 'bdsl/pkg'

module BDSL
  module CMD
    class Interaction

      def self.start(*cmd)
        puts "CMD: #{$0}"
        @goToEnv = nil
        @fullCmd = File.expand_path("#{$0}")
        cmd[0].each do |c|
          @fullCmd = @fullCmd + " #{c}"
        end
        puts @fullCmd
        if cmd[0].nil?
          puts "Usage:"
          exit(1)
        end
        puts "#{cmd} #{cmd.length}"
        init('/opt/apps/etc/cuntainer.yml')
        case cmd[0][0]
          when "install"
          install(cmd)
          when "env"
          puts "set env"
          @goToEnv = "1"
          install(cmd)
          when "list"
          list(cmd)
          else
          exit(1)
        end
      end

      def self.init(path)
        @config = Configuration.new(path)
        @config.info_config
      end
      #fetch/build/install
      def self.install(args)
        @config.set_full_cmd(@fullCmd)
        unless @goToEnv.nil?
          @config.goToEnv("go")
          puts "set config gotoenv"

        end
        pkg = Pkg.load(@config,args[0][1])
        puts "Try install #{args[0][1]} #{pkg.getVersion}"

        pkg.show_info
        if ENV['BUILDING'].nil?
          puts "Prepare build env"
          pkg.prepareBuildEnv
        else
          puts "Start build env"
          #pkg._preBuild
          pkg.do_build
        end
        p pkg.name
      end

      def self.list(args)
        puts "List #{args}"
      end

    end
  end
end
