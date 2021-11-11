# typed: false
# frozen_string_literal: true

# This file was generated by GoReleaser. DO NOT EDIT.
class IzeDev < Formula
  desc "IZE is an opinionated infrastructure wrapper that allows to use multiple tools in one infra"
  homepage "https://ize.sh/"
  version "0.0.0-dev"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/kobrikx/test/releases/download/0.0.0-dev/ize_0.0.0-dev_darwin_amd64.tar.gz", :using => CurlDownloadStrategy
      sha256 "1b0ce0afcca2b83d05e66428bfea0193396025b9375048d535defc5aa8ec151c"

      def install
        bin.install "ize"
      end
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/kobrikx/test/releases/download/0.0.0-dev/ize_0.0.0-dev_linux_amd64.tar.gz", :using => CurlDownloadStrategy
      sha256 "215cefa44b6cd1f2b6b7395796b247316a13b1a705393f1fa9470082acdb599a"

      def install
        bin.install "ize"
      end
    end
  end

  test do
    system "#{bin}/ize"
  end
end
