require 'bdsl/pkg'
require 'json'
require 'open3'
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
      @pkgMetaFile = "#{@pkg.out}/.mdat/pkg"

    end

    def out
      @pkg.out
    end

    def _postBuild
      pkgReqOnRun = []
      @pkg.requireOnRun.split.each do |reqPkg|
        pkgReqOnRun.push(reqPkg)
      end
      pkgHash = {:name => @pkg.name,
        :version => @pkg.getVersion,
        :extra_version => @pkg.extra_version,
        :pkg_rule_sha => @pkg.sha,
        :pkg_sha => "ds",
        :run_require => pkgReqOnRun
      }

      until File.directory?("#{@pkg.out}/.mdat")
        Dir.mkdir("#{@pkg.out}/.mdat")
      end

      File.open(@pkgMetaFile, File::RDWR|File::CREAT, 0644) {|f|
        f.truncate(0)
        f.write("#{pkgHash.to_json}")
      }
    end

    def needBuild
      if File.directory?("#{@pkg.out}/.mdat")
        puts " directory exists: #{@pkg.out}"
        pkgJson = ''
        File.open(@pkgMetaFile, File::RDONLY, 0644) {|f|
          pkgJson = f.read()
        }

        puts "pkg json #{pkgJson}"
        return false
      end
      return true
    end

    def do_build
      if needBuild
        _preBuild
        instance_eval(&@buildBlock)
        _postBuild
      end
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
      puts "PKG dir #{@pkg.pkg_dir}"
      File.chmod(600,"#{@pkg.pkg_dir}/#{val}")
      status = Open3.popen3(ENV,"#{@pkg.pkg_dir}/#{val}") {|sin,sout,serr,wait_thr|
        sin.close
        puts = serr.read
      }
#err = system("#{@pkg.pkg_dir}/#{val}")
#      if (err != true)
#        raise "Error execution #{val} #{err}"
#      end

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

      ENV["PATH"] = "/tools/bin:/bin:/usr/bin"
      err = system(ENV,val)
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
