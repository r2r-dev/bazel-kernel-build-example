load("@aspect_bazel_lib//lib:paths.bzl", "relative_file")

def _makefile_impl(ctx):
    _hdrs = ctx.files.hdrs[:]
    _srcs = ctx.files.srcs[:]

    hdr_subs = []
    src_subs = []

    for dep in ctx.files.deps:
        if dep.extension in ["h", "hpp"]:
            _hdrs.append(dep)
        else:
            _srcs.append(dep)

    for hdr in _hdrs:
        hdr_path_rel = "/".join(relative_file(hdr.path, ctx.outputs.output_file.path).split("/")[:-1])
        for _strip_include_path in ctx.attr.strip_include_paths:
            if hdr_path_rel.endswith(_strip_include_path):
                hdr_path_rel = hdr_path_rel[:-len(_strip_include_path)]
                break
        hdr_subs.append("ccflags-y += -I$(src)/%s" % hdr_path_rel)
    hdr_subs = depset(hdr_subs).to_list()

    for src in _srcs:
        src_path_rel = relative_file(src.path, ctx.outputs.output_file.path)
        src_dir_rel = "/".join(src_path_rel.split("/")[:-1])
        src_target = src.basename[:-(len(src.extension) + 1)]
        obj = "%s/%s.o" % (src_dir_rel, src_target)
        src_subs.append("%s-y += %s" % (ctx.attr.module_name, obj))
    src_subs = depset(src_subs).to_list()

    ctx.actions.expand_template(
        template = ctx.file.template,
        output = ctx.outputs.output_file,
        substitutions = {
            "{FLAGS}": "\n".join(ctx.attr.flags),
            "{INCLUDES}": "\n".join(hdr_subs),
            "{NAME}": ctx.attr.module_name,
            "{SOURCES}": "\n".join(src_subs),
        },
    )

makefile = rule(
    implementation = _makefile_impl,
    attrs = {
        "deps": attr.label_list(allow_files = True),
        "flags": attr.string_list(default = []),
        "hdrs": attr.label_list(allow_files = True),
        "module_name": attr.string(mandatory = True),
        "output_file": attr.output(mandatory = True),
        "srcs": attr.label_list(allow_files = True),
        "strip_include_paths": attr.string_list(default = []),
        "template": attr.label(
            allow_single_file = True,
            default = "//lib:Makefile.tpl",
        ),
    },
)

