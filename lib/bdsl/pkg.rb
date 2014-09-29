require 'net/http'
require 'digest'
require 'bdsl/builder'

module BDSL
  class Pkg
    SOURCE_TYPE_UNKNOWN = 0
    SOURCE_TYPE_TAR = 1
    SOURCE_TYPE_GIT = 2
    SOURCE_TYPE_SVN = 3
    SOURCE_TYPE_HG = 4
    def self.load(config,filename)
      config
      #TODO search on subdirectory
      @pkg_dir = File.dirname("#{config.get_pkg_dir}/#{filename}.rb")
      evalFilePath = "#{config.get_pkg_dir}/#{filename}.rb"

      begin
        file = IO.read(evalFilePath)
      rescue
        puts "No such pkg #{evalFilePath}"
        exit(1)
      end
      new(config,file,filename)
    end

    def initialize(cfg,io,filename)
      @config = cfg
      @self_sha = Digest::SHA256.hexdigest(io).to_s
      puts @self_sha
      @name = nil
      @version = nil
      @source_sha256 = nil
      @source_type = SOURCE_TYPE_UNKNOWN
      @build_dir = "#{@config.get_install_dir}/build"
      @bootstrap = 0
      @type = "unknown"
      @extra_version = ""
      @buildDirectory = ""
      @requireOnBuild = ""
      @requireOnRun = ""

      instance_eval(io,filename,0)
    end

    def out
      pkgOut = "#{install_dir}/app.#{type}.#{name}-#{version}"
      if extra_version != ""
        pkgOut = pkgOut + "-#{extra_version}"
      end
      pkgOut
    end


    def name(val = nil)
      @name = val unless val.nil?
      @name
    end

    def build_dir
      @build_dir
    end

    def pkg_dir
      @pkg_dir
    end

    def version(val = nil)
      @version = val unless val.nil?
      @version
    end

    def requireOnBuild(val = nil)
      unless val.nil?
        if @requireOnBuild == ""
          @requireOnBuild = val
        else
          @requireOnBuild = @requireOnBuild + " #{val}"
        end
      end
      @requireOnBuild
    end

    def requireOnRun(val = nil)
      unless val.nil?
        if @requireOnRun == ""
          @requireOnRun = val
        else
          @requireOnRun = @requireOnRun + " #{val}"
        end
      end
      @requireOnRun
    end

    def extra_version(val = nil)
      @extra_version = val unless val.nil?
      @extra_version
    end

    def buildDirectory(val = nil)
      @buildDirectory = val unless val.nil?
      @buildDirectory
    end

    def type(val = nil)
      @type = val unless val.nil?
      @type
    end

    def build(&block)
      @builder = Builder.new(self,&block)
    end

    def bootstrap(val)
      @bootstrap = val
      @bootstrap
    end

    def do_build
      @builder.do_build
    end

    def source_sha256(val)
      @source_sha256 = val unless val.nil?
      @source_sha256
    end

    def source_url(val)
      @source_type = SOURCE_TYPE_TAR
      @source_url = val unless val.nil?
      @config.create_source_dir
      sourceFile = @source_url.split("/")[-1]
      @sourcePath = "#{@config.get_sources_dir}/#{sourceFile}"
      authotory = @source_url.split("/")[2]
      path = ""
      i = 0
      @source_url.split("/").each do |p|
        if (i > 2)
          path = path+"/"+p
        end
        i = i + 1
      end
      puts "#{authotory} -- #{path} --#{@sourcePath}"

      unless File.file?(@sourcePath)
        Net::HTTP.start(authotory) do |http|
          resp = http.get(path)
          open(@sourcePath, "wb") do |file|
            file.write(resp.body)
          end
        end
      end
      @fileSum = Digest::SHA256.file(@sourcePath).hexdigest
      @source_url
    end

    def show_info
      puts "Pkg: #{@name} version: #{@version} sha256: #{@self_sha}"
    end

    def get_source_path
      @sourcePath
    end

    def getVersion
      @version
    end

    def add_sha(val)
#      @self_sha = Digest::SHA256.hexdigest @self_sha + val
    end

    def sha
      @self_sha
    end

    def install_dir
      @config.get_install_dir
    end

    def tool_dir
      @config.get_tool_dir
    end

    def checkBuildRequire
      puts "require: build #{@requireOnBuild} run: #{@requireOnRun}"
      @requireOnBuild.split(" ").each do |pname|
        pkg = Pkg.load(@config,pname)
      end
    end

    def prepareRunEnv
      puts "out"
    end

    def prepareBuildEnv
      checkBuildRequire

      env = {}
      envDir = "#{@config.get_install_dir}/envs/#{@self_sha}-#{@name}-#{version}-build"
      env["SHARED_DIRS_RO"] = "/usr;/bin;/lib64"
      env["SHARED_DIRS_RW"] = "#{@config.get_install_dir}"
      env["ENV_DIR"] = envDir
      env["BUILDING"] = "1"
      env["EXEC"] = "#{@config.full_cmd}"
      puts "#{env}"
      err = system(env,"#{install_dir}/bin/prepareDir")

      if (err != true)
        raise "Error execution"
      end

      err = system(env,"#{install_dir}/bin/nsswitcher")

      if (err != true)
        raise "Error execution"
      end


    end


  end
end
