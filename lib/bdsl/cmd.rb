require 'bdsl/config'
require 'bdsl/pkg'

module BDSL
  module CMD
    class Interaction

      def self.start(*cmd)
        if cmd[0].nil?
          puts "Usage:"
          exit(1)
        end
        puts "#{cmd} #{cmd.length}"
        init('test.yaml')
        case cmd[0][0]
          when "install"
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
        pkg = Pkg.load(@config,args[0][1])
        puts "Try install #{args[0][1]} #{pkg.getVersion}"

        pkg.show_info
        p pkg.name
        #pkg._preBuild
        #pkg.do_build
      end

      def self.list(args)
        puts "List #{args}"
      end

    end
  end
end
