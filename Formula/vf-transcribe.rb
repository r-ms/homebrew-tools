class VfTranscribe < Formula
  desc "Offline speech-to-text transcription CLI (GigaAM RNNT)"
  homepage "https://voiceformula.ru"
  version "0.2.2"

  if Hardware::CPU.arm?
    url "https://github.com/r-ms/homebrew-tools/releases/download/v0.2.2/vf-transcribe-0.2.2-darwin-arm64.tar.gz"
    sha256 "7da29207db4688067d3c3273adf5b2304182b79fc2705b2afc20e0c585f2dce7"
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
