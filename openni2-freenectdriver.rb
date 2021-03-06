require 'formula'

class Openni2Freenectdriver < Formula
  homepage 'https://github.com/OpenKinect/libfreenect'
  url 'https://github.com/OpenKinect/libfreenect/archive/v0.4.1.tar.gz'
  sha1 'a72bf3d60a859fb5b54b30d6e5d52c8359c07888'
  head 'https://github.com/OpenKinect/libfreenect.git'

  option :universal

  depends_on 'cmake' => :build
  depends_on 'homebrew/science/openni2' => (build.universal?) ? ['universal'] : []

  def install
    inreplace 'OpenNI2-FreenectDriver/CmakeLists.txt',
              'extern/OpenNI-Linux-x64-2.2.0.33/Include',
              "#{HOMEBREW_PREFIX}/include/ni2"

    if build.universal?
      ENV.universal_binary
      ENV['CMAKE_OSX_ARCHITECTURES'] = Hardware::CPU.universal_archs.as_cmake_arch_flags
    end

    mkdir 'build'
    cd 'build'
    system 'cmake', '..', '-DBUILD_OPENNI2_DRIVER=ON'
    system 'make'

    cd 'lib/OpenNI2-FreenectDriver'
    driver = 'libFreenectDriver.dylib'
    while File.symlink?(driver) do
      driver = File.readlink(driver)
    end
    prefix.install driver

    src = "#{prefix}/" + driver
    openni2_cellar = Dir.glob("#{HOMEBREW_PREFIX}/Cellar/openni2/*")[0]
    ln_s src, openni2_cellar + '/lib/ni2/OpenNI2/Drivers/libFreenectDriver.dylib', :force => true
    ln_s src, openni2_cellar + '/share/openni2/tools/OpenNI2/Drivers/libFreenectDriver.dylib', :force => true
    ln_s src, openni2_cellar + '/share/openni2/samples/Bin/OpenNI2/Drivers/libFreenectDriver.dylib', :force => true
  end
end
