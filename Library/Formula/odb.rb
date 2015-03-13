class Odb < Formula
  homepage "http://www.codesynthesis.com/products/odb/"
  url "http://www.codesynthesis.com/download/odb/2.4/odb-2.4.0.tar.gz"
  sha256 "169103a7829b9d8b2fdf5c267d18acc3d47c964d355c7af335d75c63b29c52b5"

  depends_on "gcc" => :build
  depends_on "libcutl" => :build

  def install
    gcc_short_version = `echo $CXX | cut -d- -f2`.strip
    gcc_plugin_dir = `echo $(dirname $($CXX -print-libgcc-file-name))/plugin/include`.strip

    unless File.exist?("#{gcc_plugin_dir}/libiberty.h")
      ln_s "#{gcc_plugin_dir}/libiberty-#{gcc_short_version}.h",
           "#{gcc_plugin_dir}/libiberty.h",
           :force => true
    end

    File.open("doc/default.options", "w") do |f|
      f << "# Default ODB options file. This file is automatically loaded by the ODB\n"
      f << "# compiler and can be used for installation-wide customizations, such as\n"
      f << "# adding an include search path for a commonly used library. For example:\n"
      f << "#\n"
      f << "# -I /opt/boost_1_45_0\n"
      f << "#\n"
    end

    system "./configure", "--prefix=#{prefix}",
                          "--libexecdir=#{lib}",
                          "--with-options-file=#{prefix}/etc/odb/default.options",
                          "CXXFLAGS=-fno-devirtualize"
    system "make", "install"

    (prefix/"etc/odb").install "doc/default.options"
  end

  fails_with :clang do
    cause <<-EOS.undent
    Oh! It seems that you only have clang available, or GCC wasn't found!
    Make sure you GCC is installed and recognized by homebrew.
    EOS
  end

  test do
    system "odb", "-v"
  end
end
