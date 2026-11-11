class Diga < Formula
  desc "Offline push-to-talk dictation for macOS, built for coding agents"
  homepage "https://github.com/r-ms/diga"
  url "https://github.com/r-ms/diga/archive/refs/tags/v0.1.10.tar.gz"
  sha256 "abdef7b11924a41af47ecf78f708e1384d3c65a5739e978752fd9ed2a4002a58"
  license "MIT"

  depends_on arch: :arm64
  depends_on macos: :sonoma
  depends_on "python@3.12"
  depends_on "uv"

  def install
    # The keg holds a pure-Python wheel, a launcher script and diga.app. On first run the script
    # builds the Python environment (PyTorch, MLX, …) in ~/Library/Application Support/diga/python:
    # in a keg, Homebrew rewrites library IDs to absolute paths, which breaks PyTorch.
    system "uv", "build", "--wheel", "--out-dir", libexec
    wheel = Dir[libexec/"diga-*.whl"].first
    (libexec/"diga-run").write <<~SH
      #!/bin/sh
      set -eu
      if [ "${1:-}" = "--version" ]; then echo "diga #{version}"; exit 0; fi
      root="$HOME/Library/Application Support/diga/python"  # only this folder is managed here
      env="$root/#{version}"
      if [ ! -f "$env/.ready" ]; then  # missing, or an earlier setup was interrupted
        echo "diga: first start — installing its Python packages (1-2 minutes, once)…" >&2
        rm -rf "$env"
        mkdir -p "$root"
        "#{formula_opt_bin("uv")}/uv" venv --quiet \\
          --python "#{formula_opt_bin("python@3.12")}/python3.12" "$env"
        "#{formula_opt_bin("uv")}/uv" pip install --quiet --python "$env/bin/python" \\
          "diga[ru,parakeet] @ file://#{opt_libexec}/#{File.basename(wheel)}"
        touch "$env/.ready"
        for old in "$root"/*; do
          [ "$old" = "$env" ] || rm -rf "$old"
        done
      fi
      exec "$env/bin/diga" "$@"
    SH
    chmod 0755, libexec/"diga-run"
    bin.install_symlink libexec/"diga-run" => "diga"

    # diga.app: macOS asks for the microphone and the keyboard in diga's name, not Python's.
    # It must not change between versions (same signature = permissions survive upgrades).
    app = prefix/"diga.app/Contents"
    (app/"MacOS").mkpath
    (app/"Resources").mkpath
    system ENV.cc, "-O2", "-framework", "ApplicationServices", "-o", app/"MacOS/diga",
           "macos/launcher.c"
    cp "macos/Info.plist", app/"Info.plist"
    (app/"Resources/run").write <<~SH
      #!/bin/sh
      exec "#{opt_libexec}/diga-run" "$@"
    SH
    chmod 0755, app/"Resources/run"
    system "codesign", "--force", "--sign", "-", "--identifier", "io.github.diga", prefix/"diga.app"
  end

  def caveats
    <<~EOS
      Set diga up and download its models (about 3.5 GB, once), then start it now and at login:
        diga models --download default
        brew services start diga
      Hold the right ⌘ and speak.

      macOS asks for the microphone, Input Monitoring and Accessibility for "diga": allow
      them (the menu-bar ⚠ opens the right page of System Settings).
      Log: `diga logs`. Check permissions: `diga doctor`.
      Uninstalling leaves ~/Library/Application Support/diga/python (its packages) behind.
    EOS
  end

  service do
    run [opt_prefix/"diga.app/Contents/MacOS/diga"]
    keep_alive successful_exit: false
    process_type :interactive
    log_path var/"log/diga.log"
    error_log_path var/"log/diga.log"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/diga --version")
  end
end
