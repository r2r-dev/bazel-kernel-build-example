load("@aspect_bazel_lib//lib:paths.bzl", "relative_file")

def makefile(**kwargs):
    _makefile(
        template = "Makefile.tpl",
        **kwargs,
    )

def _makefile_impl(ctx):
    hdrs = []
    for hdr in ctx.files.hdrs:
        hdr_path_rel = "/".join(relative_file(hdr.path, ctx.outputs.output_file.path).split("/")[:-1])
        hdrs.append("ccflags-y += -I$(src)/%s" % hdr_path_rel)
    hdrs = depset(hdrs).to_list()

    srcs = []
    for src in ctx.files.srcs:
        src_path_rel = relative_file(src.path, ctx.outputs.output_file.path)
        src_dir_rel = "/".join(src_path_rel.split("/")[:-1])
        src_target = src.basename[:-(len(src.extension)+1)]
        obj = "%s/%s.o" % (src_dir_rel, src_target)
        srcs.append("%s-y += %s" % (src_target, obj))
    srcs = depset(srcs).to_list()

    ctx.actions.expand_template(
        template = ctx.file.template,
        output = ctx.outputs.output_file,
        substitutions = {
            "{INCLUDES}": "\n".join(hdrs),
            "{SOURCES}": "\n".join(srcs),
            "{FLAGS}": "\n".join(ctx.attr.flags),
            "{NAME}": ctx.attr.module_name,
        },
    )

_makefile = rule(
    implementation = _makefile_impl,
    attrs = {
        "module_name": attr.string(mandatory = True),
        "srcs": attr.label_list(allow_files = True),
        "hdrs": attr.label_list(allow_files = True),
        "flags": attr.string_list(default = []),
        "template": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
        "output_file": attr.output(mandatory = True),
    },
)
