class Diga < Formula
  desc "Offline push-to-talk dictation for macOS, built for coding agents"
  homepage "https://github.com/r-ms/diga"
  url "https://github.com/r-ms/diga/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "b1ffab9ee05b80e2b342c982f48793a3ba9aeac78c58ace19f560b3578606bf3"
  license "MIT"

  depends_on arch: :arm64
  depends_on macos: :sonoma
  depends_on "python@3.12"
  depends_on "uv"

  def install
    # The keg holds a pure-Python wheel and a launcher. On first run the launcher builds the
    # Python environment (PyTorch, MLX, …) in ~/Library/Application Support/diga/python: in a keg,
    # Homebrew rewrites library IDs to absolute paths, which breaks PyTorch's extensions.
    system "uv", "build", "--wheel", "--out-dir", libexec
    wheel = Dir[libexec/"diga-*.whl"].first
    (bin/"diga").write <<~SH
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
  end

  def caveats
    <<~EOS
      Set diga up and download its models (about 3.5 GB, once), then start it now and at login:
        diga models --download default
        brew services start diga
      Hold the right ⌘ and speak.

      macOS asks for the microphone; switch on Accessibility and Input Monitoring for diga's
      Python in System Settings → Privacy & Security. `diga doctor` shows what is missing.
      Uninstalling leaves ~/Library/Application Support/diga/python (its packages) behind.
    EOS
  end

  service do
    run [opt_bin/"diga"]
    keep_alive successful_exit: false
    process_type :interactive
    log_path var/"log/diga.log"
    error_log_path var/"log/diga.log"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/diga --version")
  end
end
