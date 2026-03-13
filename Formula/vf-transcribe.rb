class VfTranscribe < Formula
  desc "Offline speech-to-text transcription CLI (GigaAM RNNT)"
  homepage "https://voiceformula.ru"
  version "0.2.0"

  if Hardware::CPU.arm?
    url "https://github.com/r-ms/homebrew-tools/releases/download/v0.2.0/vf-transcribe-0.2.0-darwin-arm64.tar.gz"
    sha256 "013b501c664dc3a7002cef6c16eba2c88c210c4eb9e1fd775e19c2eaba8a31df"
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
