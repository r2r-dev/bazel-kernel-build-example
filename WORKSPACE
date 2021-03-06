workspace(name = "kernel-build-example")

load(
    "@bazel_tools//tools/build_defs/repo:http.bzl",
    "http_archive",
)

http_archive(
    name = "io_bazel_stardoc",
    sha256 = "c9794dcc8026a30ff67cf7cf91ebe245ca294b20b071845d12c192afe243ad72",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/stardoc/releases/download/0.5.0/stardoc-0.5.0.tar.gz",
        "https://github.com/bazelbuild/stardoc/releases/download/0.5.0/stardoc-0.5.0.tar.gz",
    ],
)

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()

http_archive(
    name = "bazel_skylib",
    sha256 = "c6966ec828da198c5d9adbaa94c05e3a1c7f21bd012a0b29ba8ddbccb2c93b0d",
    urls = [
        "https://github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
    ],
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

BAZEL_LIB_COMMIT = "0d2981f2881cbe3eabc8264a5147d843c577b8cf"

http_archive(
    name = "aspect_bazel_lib",
    sha256 = "8a3bfec57cb57c79b2540f16b34c348415724b67be55f616785b4f35c555ad96",
    strip_prefix = "bazel-lib-%s" % BAZEL_LIB_COMMIT,
    urls = [
        "https://github.com/aspect-build/bazel-lib/archive/%s.tar.gz" % BAZEL_LIB_COMMIT,
    ],
)

RULES_CC_COMMIT = "68cb652a71e7e7e2858c50593e5a9e3b94e5b9a9"

http_archive(
    name = "rules_cc",
    sha256 = "070e6220f6e695bb2e0d2f11ec8de137661d3700178cff13170c5aebed0b4f08",
    strip_prefix = "rules_cc-%s" % RULES_CC_COMMIT,
    urls = [
        "https://github.com/bazelbuild/rules_cc/archive/%s.tar.gz" % RULES_CC_COMMIT,
    ],
)

RULES_TWEAG_COMMIT = "a388ab60dea07c3fc182453e89ff1a67c9d3eba6"

http_archive(
    name = "io_tweag_rules_nixpkgs",
    sha256 = "6bedf80d6cb82d3f1876e27f2ff9a2cc814d65f924deba14b49698bb1fb2a7f7",
    strip_prefix = "rules_nixpkgs-%s" % RULES_TWEAG_COMMIT,
    urls = ["https://github.com/tweag/rules_nixpkgs/archive/%s.tar.gz" % RULES_TWEAG_COMMIT],
)

load(
    "@io_tweag_rules_nixpkgs//nixpkgs:repositories.bzl",
    "rules_nixpkgs_dependencies",
)

rules_nixpkgs_dependencies()

load(
    "@io_tweag_rules_nixpkgs//nixpkgs:nixpkgs.bzl",
    "nixpkgs_cc_configure",
    "nixpkgs_local_repository",
    "nixpkgs_package",
)

nixpkgs_local_repository(
    name = "host_nixpkgs",
    nix_file = "//nix:nixpkgs.nix",
    nix_file_deps = [
        "//:flake.lock",
        "//nix:bazel.nix",
    ],
)

NIX_REPOS = {
    "nixpkgs": "@host_nixpkgs",
}

nixpkgs_cc_configure(
    name = "toolchain-linux-x86_64",
    exec_constraints = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    repositories = NIX_REPOS,
    target_constraints = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
)

nixpkgs_package(
    name = "kleaf",
    attribute_path = "kleaf",
    nix_file = "//nix:bazel.nix",
    nix_file_deps = [
        "//:flake.lock",
        "//nix:bazel.nix",
        "//nix:nixpkgs.nix",
        "//nix:01.kleaf.patch",
        "//nix:02.bazel_common_rules.patch",
    ],
    repositories = NIX_REPOS,
)

nixpkgs_package(
    name = "kernel_toolchain_x86_64",
    build_file_content = 'exports_files(["build.config"])',
    nix_file = "//nix:build.config.x86_64.nix",
    nix_file_deps = [
        "//:flake.lock",
        "//nix:nixpkgs.nix",
    ],
    repositories = NIX_REPOS,
)

nixpkgs_package(
    name = "kernel_toolchain_aarch64",
    build_file_content = 'exports_files(["build.config"])',
    nix_file = "//nix:build.config.aarch64.nix",
    nix_file_deps = [
        "//:flake.lock",
        "//nix:nixpkgs.nix",
    ],
    repositories = NIX_REPOS,
)

http_archive(
    name = "linux",
    build_file = "//3rdparty:BUILD.kernel",
    patch_args = ["-p1"],
    patches = ["//3rdparty:01.kernel.patch"],
    sha256 = "ca13fa5c6e3a6b434556530d92bc1fc86532c2f4f5ae0ed766f6b709322d6495",
    strip_prefix = "linux-4.15.18",
    url = "https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.15.18.tar.gz",
)
