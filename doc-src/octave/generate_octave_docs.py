#!/usr/bin/env python3
"""Generate the Octave/Matlab API reference from the M-file help text.

One page is written per API group, with the functions of that group as
sections, so the navigation stays readable. The mapping below is the single
place where a new M-file has to be registered; anything not listed lands in
the group "misc" with a warning.
"""

import os
import pathlib
import subprocess
import sys

# Group slug, page title, member functions. The order within a group is the
# order on the page.
GROUPS = {
    "CSXCAD": [
        ("geometry", "Geometry", [
            "AddBox", "AddCurve", "AddCylinder", "AddCylindricalShell",
            "AddLinPoly", "AddPoint", "AddPolygon", "AddPolyhedron",
            "AddRotPoly", "AddSphere", "AddSphericalShell", "AddWire",
        ]),
        ("materials", "Materials", [
            "AddMetal", "AddConductingSheet", "AddMaterial",
            "SetMaterialProperty", "SetMaterialWeight",
            "SetBackgroundMaterial", "AddLumpedElement",
            "AddDebyeMaterial", "AddLorentzMaterial",
            "AddDjordjevicSarkarMaterial", "CalcDebyeMaterial",
            "CalcDrudeMaterial", "CalcLorentzMaterial",
            "CalcDjordjevicSarkarApprox", "AddDiscMaterial",
            "CreateDiscMaterial", "Convert_VF_DiscMaterial",
        ]),
        ("mesh", "Mesh", [
            "DefineRectGrid", "SmoothMesh", "SmoothMeshLines",
            "SmoothMeshLines2", "AutoSmoothMeshLines", "RecursiveSmoothMesh",
            "DetectEdges", "AnalyseMesh", "CheckMesh",
        ]),
        ("excitations", "Excitations", [
            "AddExcitation", "AddPlaneWaveExcite", "SetExcitationWeight",
            "SetExcitationWeightFile",
        ]),
        ("probes_dumps", "Probes and Field Dump", [
            "AddProbe", "AddDump",
        ]),
        ("import_export", "Import & Export", [
            "ImportPLY", "ImportSTL", "export_empire", "export_excellon",
            "export_gerber", "export_povray",
        ]),
        ("misc", "Misc", [
            "InitCSX", "AddPropAttribute", "CSXGeomPlot", "WriteCSX",
            "struct_2_xml", "DirChar2Int", "isOctave", "searchBinary",
        ]),
    ],
    "openEMS": [
        ("simulation", "Simulation", [
            "InitFDTD", "InitCylindricalFDTD", "SetBoundaryCond", "AddPML",
            "WriteOpenEMS", "RunOpenEMS", "RunOpenEMS_Parallel", "InitQueue",
            "setup",
        ]),
        ("excitations", "Excitations", [
            "SetGaussExcite", "SetSinusExcite", "SetDiracExcite",
            "SetStepExcite", "SetCustomExcite",
        ]),
        ("ports", "Ports", [
            "AddLumpedPort", "AddCurvePort", "AddMSLPort", "AddStripLinePort",
            "AddCPWPort", "AddCoaxialPort", "AddWaveGuidePort",
            "AddRectWaveGuidePort", "AddCircWaveGuidePort", "AddMRStub",
        ]),
        ("nf2ff", "Near-Field to Far-Field Transform", [
            "CreateNF2FFBox", "CalcNF2FF", "AnalyzeNF2FF",
        ]),
        ("postprocessing", "Post-Processing", [
            "calcPort", "calcLumpedPort", "calcTLPort", "calcWGPort",
            "calc_ypar", "ReadUI", "DFT_time2freq", "FFT_time2freq",
            "AR_estimate", "harminv", "DelayFidelity", "CalcSAR",
            "plotRefl", "plotFF3D", "plotFFdB", "polarFF",
            "ReadHDF5Attribute", "ReadHDF5Dump", "ReadHDF5FieldData",
            "ReadHDF5Mesh", "WriteHDF5", "PlotHDF5FieldData",
            "GetField_Interpolation", "GetField_Range", "GetField_SubSampling",
            "GetField_TD2FD", "ConvertHDF5_VTK",
        ]),
        ("fielddump", "Field Dump Export", [
            "Dump2VTK", "DumpFF2VTK",
        ]),
        ("optimization", "Optimization", [
            "optimize", "optimizer_asco_sim",
        ]),
        ("misc", "Misc", [
            "physical_constants", "openEMS_resource_path", "CleanupSimPath",
            "h5writemode", "Add2Queue", "CheckQueue", "FinishQueue",
            "ResultsQueue", "FindFreeSSH", "queue_addProcess",
            "queue_checkProcess", "queue_delProcess",
        ]),
    ],
}

_BOILERPLATE = [
    "openEMS matlab/octave interface",
    "openEMS matlab interface",
    "openEMS Matlab/Octave interface",
    "CSXCAD matlab interface",
    "adding openEMS+CSXCAD path",
    "disable recursive rmdir confirmation",
    "set page screen output to",
]


def get_octave_helptext(cwd, funcname):
    # Arbitrary Octave code execution is possible via filename injection.
    # We assume all files committed into the project tree are non-malicious,
    # so never use it with untrusted files!
    retval = subprocess.run(
        ["octave", "--eval", "display(get_help_text('%s'));" % funcname],
        cwd=cwd,
        capture_output=True
    )
    retval.check_returncode()
    return retval.stdout.decode("UTF-8")


def modify_helptext(helptext):
    helptext_lines = helptext.split("\n")

    # all raw docstrings have 1 leading space, remove them
    for idx, line in enumerate(helptext_lines):
        if line and line[0] == ' ':
            helptext_lines[idx] = line[1:]

        stripped = helptext_lines[idx].strip()
        if (
            any(pat in stripped for pat in _BOILERPLATE) or
            (stripped.startswith("openEMS_root") and "=" in stripped)
        ):
            helptext_lines[idx] = ""

    # skip leading blank lines to find the first meaningful line (func prototype)
    func_prototype = ""
    start_idx = 0
    for idx, line in enumerate(helptext_lines):
        if line.strip():
            func_prototype = line.strip()
            start_idx = idx + 1
            break

    rest = "\n".join(helptext_lines[start_idx:])
    return func_prototype, rest


def get_cached_helptext(cwd, cachedir, mfile, funcname):
    """Return the raw help text, using a cache keyed on the M-file mtime."""
    cached = cachedir / (funcname + ".txt")
    if cached.is_file() and os.path.getmtime(cached) > os.path.getmtime(mfile):
        return cached.read_text(encoding="UTF-8")

    print("Reading help text of %s..." % funcname)
    text = get_octave_helptext(cwd, funcname)
    cached.write_text(text, encoding="UTF-8")
    return text


def is_function_file(mfile):
    """True if the M-file defines a function, False if it is a script."""
    with open(mfile, encoding="UTF-8", errors="replace") as f:
        for line in f:
            stripped = line.strip()
            if not stripped or stripped.startswith(("%", "#")):
                continue
            return stripped.startswith("function")
    return False


def render_function(cwd, cachedir, mfile, funcname):
    """Render one function or script as a Markdown section."""
    text = get_cached_helptext(cwd, cachedir, mfile, funcname)
    func_usage, rest = modify_helptext(text)
    func_usage = func_usage.lstrip()

    out = ["## %s\n" % funcname]

    if not is_function_file(mfile):
        # A script (e.g. physical_constants) has no signature to document.
        out.append(func_usage)
        out.append(rest)
        return "\n".join(out)

    func_prototype = func_usage.split("=")[-1].strip()
    func_prototype = func_prototype.replace("function ", "")

    # The M-file defines a function, so the first line of its help text has to
    # be that function's definition. If the name is missing, the help text was
    # not what we expected -- e.g. Octave printed something of its own first.
    # Writing that out produces a reference page full of nonsense, so refuse
    # instead: a stale cache entry would otherwise never be noticed again.
    if funcname not in func_prototype:
        print(
            'ERROR: help text of "%s" does not look like a function '
            'definition.\n  Extracted prototype: %r\n  Full first line: %r'
            % (funcname, func_prototype, func_usage),
            file=sys.stderr,
        )
        return None

    out.append("```{function} %s\n```\n" % func_prototype)
    out.append("Full definition:\n")
    out.append("```{code-block} matlab\n%s\n```\n" % func_usage)
    out.append(rest)
    return "\n".join(out)


def generate_doc(subproject):
    cwd = "../../%s/matlab/" % subproject
    mdir = pathlib.Path(cwd)
    outdir = pathlib.Path("./autogenerated/%s" % subproject)
    cachedir = outdir / ".cache"
    cachedir.mkdir(parents=True, exist_ok=True)

    available = sorted(f.with_suffix("").name for f in mdir.glob("*.m"))
    if not available:
        print("No input files found!")
        print('This script must be executed from "openEMS-Project/doc-src/octave" ')
        print('and the directory "openEMS-Project/%s/matlab/" must be non-empty!' % subproject)
        sys.exit(1)

    groups = [(slug, title, list(members)) for slug, title, members in GROUPS[subproject]]
    listed = {name for _, _, members in groups for name in members}

    missing = [name for name in listed if name not in available]
    if missing:
        print("Note: %s: listed but no M-file found: %s"
              % (subproject, ", ".join(sorted(missing))))

    unlisted = [name for name in available if name not in listed]
    if unlisted:
        print("Note: %s: not assigned to a group, adding to Misc: %s"
              % (subproject, ", ".join(unlisted)))
        for slug, _, members in groups:
            if slug == "misc":
                members.extend(unlisted)
                break

    failed = []
    for slug, title, members in groups:
        sections = []
        for funcname in members:
            mfile = mdir / (funcname + ".m")
            if not mfile.is_file():
                continue
            rendered = render_function(cwd, cachedir, mfile, funcname)
            if rendered is None:
                failed.append(funcname)
                continue
            sections.append(rendered)

        with open(outdir / ("%s.md" % slug), "w") as f:
            f.write("# %s\n\n" % title)
            f.write("\n".join(sections))

    if failed:
        print("ERROR: could not generate help text for: %s" % ", ".join(failed),
              file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    generate_doc("CSXCAD")
    generate_doc("openEMS")
