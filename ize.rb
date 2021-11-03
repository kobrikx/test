# typed: false
# frozen_string_literal: true

# This file was generated by GoReleaser. DO NOT EDIT.
class Ize < Formula
  desc "IZE is an opinionated infrastructure wrapper that allows to use multiple tools in one infra"
  homepage "https://ize.sh/"
  version "0.0.1"
  license "MIT"
  depends_on :macos

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/kobrikx/test/releases/download/0.0.1/ize_0.0.1_darwin_amd64.tar.gz", :using => CurlDownloadStrategy
      sha256 "23aceb6101eb42ca242b2ba0298f07964f36d2891c8f8ba7901522c1043fa017"

      def install
        bin.install "ize"
      end
    end
  end

  test do
    system "#{bin}/ize"
  end
end
