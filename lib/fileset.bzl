def _fileset_impl(ctx):
    srcs = depset(order = "postorder", transitive = [src.files for src in ctx.attr.srcs])

    remap = {}
    for a, b in ctx.attr.maps.items():
        remap[ctx.label.relative(a)] = b

    cmd = ""
    for f in ctx.files.srcs:
        label = f.owner if f.is_source else f.owner.relative(f.basename)
        if label in remap:
            dest = remap[label]
            fd = ctx.actions.declare_file(dest)
            cmd += "mkdir -p " + fd.dirname + "\n"
            cmd += "cp -f '" + f.path + "' '" + fd.path + "'\n"

    script = ctx.actions.declare_file(ctx.label.name + ".cmd.sh")
    ctx.actions.write(output = script, content = cmd)

    # Execute the command
    ctx.actions.run_shell(
        inputs = (
            ctx.files.srcs +
            [script]
        ),
        outputs = ctx.outputs.outs,
        mnemonic = "fileset",
        command = "set -e; sh " + script.path,
        use_default_shell_env = True,
    )

_fileset = rule(
    attrs = {
        "maps": attr.string_dict(
            mandatory = True,
            allow_empty = False,
        ),
        "outs": attr.output_list(
            mandatory = True,
            allow_empty = False,
        ),
        "srcs": attr.label_list(allow_files = True),
    },
    executable = False,
    implementation = _fileset_impl,
)

def fileset(name, srcs = [], mappings = {}, tags = [], **kwargs):
    outs = []
    maps = {}
    rem = []
    for src in srcs:
        done = False
        for prefix, destination in mappings.items():
            if src.startswith(prefix):
                f = destination + src[len(prefix):]
                maps[src] = f
                outs.append(f)
                done = True
        if not done:
            rem.append(src)

    if outs:
        _fileset(
            name = name + ".map",
            srcs = srcs,
            maps = maps,
            outs = outs,
            tags = tags,
        )

    native.filegroup(
        name = name,
        srcs = outs + rem,
        tags = tags,
        **kwargs
    )

