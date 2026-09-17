class Yabai < Formula
  desc "A tiling window manager for macOS based on binary space partitioning."
  homepage "https://github.com/ImTheSquid/yabai"
  head "https://github.com/ImTheSquid/yabai.git", branch: "master"

  depends_on :macos => :big_sur

  def install
    man.mkpath

    system "make", "-j1", "install"
    system "codesign", "-fs", "-", "#{buildpath}/bin/yabai"

    bin.install "#{buildpath}/bin/yabai"
    (pkgshare/"examples").install "#{buildpath}/examples/yabairc"
    (pkgshare/"examples").install "#{buildpath}/examples/skhdrc"
    man1.install "#{buildpath}/doc/yabai.1"
  end

  def caveats; <<~EOS
    The sudoers rule pins this binary's sha256. Regenerate it after any build
    that picks up a new commit:
      echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(\which yabai) | cut -d " " -f 1) $(\which yabai) --load-sa"
      sudo visudo -f /private/etc/sudoers.d/yabai

    Then reload the scripting addition:
      sudo yabai --load-sa
    EOS
  end

  test do
    assert_match "yabai-v", shell_output("#{bin}/yabai --version")
  end
end
