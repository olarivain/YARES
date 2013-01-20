require 'rubygems'
require 'xcodebuilder'

# x86 target
builder = XcodeBuilder::XcodeBuilder.new do |config|
  # basic workspace config
  config.build_dir = :derived
  config.workspace_file_path = "YARES.xcworkspace"
  config.scheme = "YARES"
  config.configuration = "Release" 
  config.sdk = "macosx"
  config.skip_clean = false
  config.verbose = false
  config.info_plist = "./Resources/Info.plist"
  config.skip_dsym = true
  config.skip_clean = false
  config.verbose = false
  config.increment_plist_version = true
  config.tag_vcs = true
  config.pod_repo = "kra"
  config.podspec_file = "YARES.podspec"
  
  # tag and release with git
  config.release_using(:git) do |git|
    git.branch = "master"
  end
end

desc "Full clean"
task :clean do
	# dump temp build folder
	FileUtils.rm_rf "./build"
	FileUtils.rm_rf "./pkg"

	# and cocoa pods artifacts
	FileUtils.rm_rf builder.configuration.workspace_file_path
	FileUtils.rm_rf "Podfile.lock"
end

desc "pod requires a full clean and runs pod install"
task :pod => :clean do
	system "pod install"
end

desc "builds both targets and releases the pod"
task :release => :pod do
	builder.pod_release
end