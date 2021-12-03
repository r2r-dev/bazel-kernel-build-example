### Compile kernel with
`bazel build @linux//:kernel`
or
`bazel build @linux//:kernel --platforms=aarch64-linux`

### Compile out-of-tree kernel module with
`bazel build //oot:hello`
or
`bazel build //oot:hello --platforms=aarch64-linux`

### Compile out-of-tree kernel module for x86_64 and aarch64:
`bazel build //:split_hello`
