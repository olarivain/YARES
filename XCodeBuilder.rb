open require 'fileutils'

class Builder
  
  attr_accessor :name
  attr_accessor :libname
  attr_accessor :headerFolder
  attr_accessor :configuration
  
  def initialize(name, configuration = "Release")
    @name = name
    @libname = "lib#{name}.a"
    @headerFolder = name
    @configuration = configuration
  end
  
  def deploy
    version_file = File.new("version")
    version_number = version_file.gets
    
    base_deployment_folder = "/usr/local/xcodelibs/" + name
    deployment_folder = base_deployment_folder + "/" + version_number
    FileUtils.rm_f deployment_folder
    FileUtils.mkdir_p deployment_folder
    
    FileUtils.cp_r("build/"+configuration+"/"+libname, deployment_folder)
    FileUtils.cp_r("build/"+configuration+"/usr/local/include/"+headerFolder, deployment_folder)
    
    symlinkName = base_deployment_folder + "/LATEST"
    puts "link " + symlinkName
    # get rid of symlink if it already exists
    if File.exist?(symlinkName)
      FileUtils.rm(symlinkName)
    end
    File.symlink(deployment_folder, symlinkName)


  end
  
  def buildAndDeploy
    build
    deploy
  end
  
  def build
    cleanCmd = "xcodebuild -configuration #{configuration} -target #{name} clean"
    system cleanCmd
    buildCmd = "xcodebuild -configuration #{configuration} -target #{name}"
    system buildCmd
    deploy
  end
  
  
  
end