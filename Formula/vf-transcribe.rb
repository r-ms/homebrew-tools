class VfTranscribe < Formula
  desc "Offline speech-to-text transcription CLI (VAD + GigaAM)"
  homepage "https://voiceformula.ru"
  version "0.1.0"

  if Hardware::CPU.arm?
    url "https://github.com/r-ms/homebrew-tools/releases/download/v0.1.0/vf-transcribe-0.1.0-darwin-arm64.tar.gz"
    sha256 "df2af80072139691471989fbc6513933cb5c85ab70117c663084703635771f1d"
  else
    url "https://github.com/r-ms/homebrew-tools/releases/download/v0.1.0/vf-transcribe-0.1.0-darwin-x86_64.tar.gz"
    sha256 "PLACEHOLDER_X86_64_SHA256"
  end

  def install
    bin.install "vf-transcribe"
  end

  test do
    assert_match "usage", shell_output("#{bin}/vf-transcribe --help", 0).downcase
  end
end
