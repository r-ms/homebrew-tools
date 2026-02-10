class VfTranscribe < Formula
  desc "Offline speech-to-text transcription CLI (VAD + GigaAM)"
  homepage "https://voiceformula.ru"
  version "0.1.1"

  if Hardware::CPU.arm?
    url "https://github.com/r-ms/homebrew-tools/releases/download/v0.1.1/vf-transcribe-0.1.1-darwin-arm64.tar.gz"
    sha256 "4c6392a6aaba374ab972ef15010cc233020c3719798242cf22a71b3de40ec599"
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
