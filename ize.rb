# typed: false
# frozen_string_literal: true

# This file was generated by GoReleaser. DO NOT EDIT.
class Ize < Formula
  desc "IZE is an opinionated infrastructure wrapper that allows to use multiple tools in one infra"
  homepage "https://ize.sh/"
  version "0.0.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/kobrikx/test/releases/download/0.0.3/ize_0.0.3_darwin_amd64.tar.gz", :using => CurlDownloadStrategy
      sha256 "4494f168f28569e87974befa3727d6aad7c88c3708a1926887b39b2e40783512"

      def install
        bin.install "ize"
      end
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/kobrikx/test/releases/download/0.0.3/ize_0.0.3_linux_amd64.tar.gz", :using => CurlDownloadStrategy
      sha256 "3489b785e8358514f1eee5b58d36c305e7996ac26b4f4eb5ecb490d615c57391"

      def install
        bin.install "ize"
      end
    end
  end

  test do
    system "#{bin}/ize"
  end
end
