require 'bdsl/pkg'
require 'fileutils'

module BDSL
  class Builder
    def initialize(pkg,&block)
      @env = {}
      @pkg = pkg
      @has_error = 0
      @baseBuildDir = @pkg.build_dir
      @source_pkg = @pkg.get_source_path
      @buildDir = "#{@pkg.build_dir}/#{@pkg.name}-#{@pkg.version}"
      @buildBlock = block

    end

    def out
      @pkg.out
    end


    def do_build
      _preBuild
      instance_eval(&@buildBlock)
    end

    def tool_dir
      toolDir = "#{@pkg.tool_dir}"
      toolDir
    end

    def prepareBuildDir
      FileUtils::mkdir_p "#{@buildDir}"
      Dir.chdir @buildDir
    end

    def preBuild(val)
      prepareBuildDir
      err = system(var)
    end

    def _preBuild
      puts "_preBuild"
      prepareBuildDir
      system("tar -xf #{@source_pkg}")
    end

    def source_pkg
      @source_pkg
    end

    def exec(val)
      Dir.chdir "#{@buildDir}/#{@pkg.name}-#{@pkg.version}"
      err = system("#{@pkg.pkg_dir}/#{val}")
      if (err != true)
        raise "Error execution #{val}"
      end

    end

    def configPhase(val)
      p val
      Dir.chdir "#{@buildDir}/#{@pkg.name}-#{@pkg.version}"
      if @pkg.buildDirectory != ""
        FileUtils::mkdir_p "#{@pkg.buildDirectory}"
        Dir.chdir "#{@pkg.buildDirectory}"
      end

      err = system(val)
      if (err != true)
        raise "Error execution #{val}"
      end
    end

    def _configPhase
    end

    def buildPhase(val)
      Dir.chdir "#{@buildDir}/#{@pkg.name}-#{@pkg.version}"

      if @pkg.buildDirectory != ""
        FileUtils::mkdir_p "#{@pkg.buildDirectory}"
        Dir.chdir "#{@pkg.buildDirectory}"
      end

      err = system(val)
      if (err != true)
        raise "Error execution #{val}"
      end
    end

    def _buildPhase
      Dir.chdir "#{@buildDir}/#{@pkg.name}-#{@pkg.version}"
      system("./configure --prefix=/opt/dst/haha")
      system("make")
      system("make instal")
    end

    def installPhase(val)
      Dir.chdir "#{@buildDir}/#{@pkg.name}-#{@pkg.version}"

      if @pkg.buildDirectory != ""
        FileUtils::mkdir_p "#{@pkg.buildDirectory}"
        Dir.chdir "#{@pkg.buildDirectory}"
      end

      err = system(val)
      if (err != true)
        raise "Error execution #{val}"
      end
    end

    def build
    end
  end
end
