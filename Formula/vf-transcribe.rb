class VfTranscribe < Formula
  desc "Offline speech-to-text transcription CLI (GigaAM RNNT)"
  homepage "https://voiceformula.ru"
  version "0.2.1"

  if Hardware::CPU.arm?
    url "https://github.com/r-ms/homebrew-tools/releases/download/v0.2.1/vf-transcribe-0.2.1-darwin-arm64.tar.gz"
    sha256 "ba0742420481f72dcf8a1011059c5c4f37287d1a1a8e0f9a22044064e5c43b1a"
  else
    odie "vf-transcribe is currently only available for Apple Silicon (arm64)"
  end

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"vf-transcribe"
  end

  test do
    assert_match "usage", shell_output("#{bin}/vf-transcribe --help", 0).downcase
  end
end
