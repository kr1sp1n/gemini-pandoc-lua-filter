# gemini-pandoc-lua-filter

A lua filter for [pandoc][1] to output [gemini][2] text.

## Example

```bash
pandoc -f html -t plain --lua-filter gemini.lua examples/simple.html
```

## Test

```bash
pandoc -f html -t plain --lua-filter gemini.lua examples/simple.html -o /tmp/simple.gmi
diff /tmp/simple.gmi test/output/simple.gmi
```
The exit code of the `diff` command should be `0`.

---

[1]: https://pandoc.org/
[2]: https://gemini.circumlunar.space/
