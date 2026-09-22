# AI Policy

AI-assisted contributions are welcome, subject to the following rules.

## Disclosure

Add a tag to your commit message when AI tools were involved:

- `Assisted-by: <tool>` — AI helped with parts of the work (e.g. suggestions, debugging)
- `Generated-by: <tool>` — AI produced a substantial portion of the code or text

The same applies to pull request descriptions and issue reports: state at the top whether AI was used.

## Sign-off

Every commit must carry a `Signed-off-by:` line certifying the [Developer Certificate of Origin](https://developercertificate.org/); `git commit -s` adds it. It is always the **last** line, with the AI tag directly above it:

```
Assisted-by: <tool>
Signed-off-by: Your Name <your@email.example>
```

Use exactly these trailers. Do not add `Co-Authored-By:`, session identifiers or links inserted by AI tooling, or other automatically generated trailers — the tag above is the disclosure this project asks for.

## Responsibility

The contributor is fully responsible for every line of code, script, documentation, or configuration submitted, regardless of how it was produced. Do not submit AI-generated content you have not read, understood, and verified. Reviewers will apply extra scrutiny to `Generated-by` submissions.

## License

The components in this project carry different open-source licenses: openEMS, AppCSXCAD, and hyp2mat are GPLv3; CSXCAD, QCSXCAD, and fparser are LGPLv3; CTB is BSD-style. By submitting a contribution you confirm it is compatible with the license of the component you are modifying. Verify that the AI tool's terms of service do not impose restrictions on its output that are incompatible with the applicable license, and avoid submitting large verbatim AI-generated blocks where copyright provenance is unclear.

## Brevity

AI output tends to be verbose. Edit it before submitting. Pull requests, commit messages, and issue reports should be as concise as a human would write them. Overly long AI-generated descriptions will be asked to be trimmed before review.
