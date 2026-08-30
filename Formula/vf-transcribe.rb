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

  # Бандл PyInstaller самодостаточен (@loader_path) и подписан ad-hoc при сборке.
  # Не давать `brew cleanup` дёргать strip: он рвёт подписи, а на arm64 это фатально.
  skip_clean "libexec"

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"vf-transcribe"
  end

  # Homebrew на этапе fix_dynamic_linkage переписывает load commands во всех Mach-O
  # внутри кеги, включая нутро бандла. Подпись при этом становится невалидной, и на
  # Apple Silicon AMFI убивает процесс сигналом 9 при загрузке libpython3.11.dylib —
  # CLI молча падал с exit 137. Хук FormulaInstaller#fix_dynamic_linkage из формулы
  # не переопределить, но post_install идёт последним (после clean, link и релокации),
  # так что чиним уже по факту: переподписываем всё, что перестало верифицироваться.
  def post_install
    # FNM_DOTMATCH обязателен: numpy держит свои dylib в _internal/numpy/.dylibs/,
    # а Dir.glob без него скрытые каталоги не обходит.
    Dir.glob("#{libexec}/**/*", File::FNM_DOTMATCH).each do |path|
      next unless File.file?(path)
      next if File.symlink?(path)
      next if !path.end_with?(".so", ".dylib") && path != "#{libexec}/vf-transcribe"
      next if quiet_system("/usr/bin/codesign", "--verify", path)

      system "/usr/bin/codesign", "--force", "--sign", "-", path
    end
  end

  test do
    assert_match "usage", shell_output("#{bin}/vf-transcribe --help").downcase
  end
end
