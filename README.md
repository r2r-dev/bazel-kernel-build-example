### Compile kernel with
`bazel build @linux//:kernel_x86_64`
`bazel build @linux//:kernel_aarch64`

### Compile out-of-tree kernel module with
`bazel build //oot:hello_x86_64`
`bazel build //oot:hello_aarch64`
