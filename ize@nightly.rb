# typed: false
# frozen_string_literal: true

# This file was generated by GoReleaser. DO NOT EDIT.
class IzeATnightly < Formula
  desc "IZE is an opinionated infrastructure wrapper that allows to use multiple tools in one infra"
  homepage "https://ize.sh/"
  version "0.0.6"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/kobrikx/test/releases/download/0.0.6/ize@nightly_0.0.6_darwin_amd64.tar.gz", :using => CurlDownloadStrategy
      sha256 "a6893c62568e81a3f70c3809035e404dc6913b558d690f9175fb52c911103d0e"

      def install
        bin.install "ize"
      end
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/kobrikx/test/releases/download/0.0.6/ize@nightly_0.0.6_linux_amd64.tar.gz", :using => CurlDownloadStrategy
      sha256 "122e5241a53c57b133c92d81bc0e3f80e2c498df898b1914da4cae78858bbaa4"

      def install
        bin.install "ize"
      end
    end
  end

  test do
    system "#{bin}/ize"
  end
end
