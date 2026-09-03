from pathlib import Path
import re
import tomllib

ROOT = Path(__file__).resolve().parents[1]

with (ROOT / "hugo.toml").open("rb") as f:
    config = tomllib.load(f)

assert config["languageCode"] == "el"
assert config["title"] == "AllGreeceWeather"
assert config["markup"]["goldmark"]["renderer"]["unsafe"] is False
assert config["security"]["enableInlineShortcodes"] is False
assert config["security"]["allowContent"] == ["^text/markdown$"]
assert config["security"]["exec"]["allow"] == "none"
assert config["security"]["http"]["urls"] == "none"

posts = list((ROOT / "content" / "posts").glob("*.md"))
for post in posts:
    text = post.read_text(encoding="utf-8")
    assert text.startswith("---\n"), post
    frontmatter = text[4:].split("\n---\n", 1)[0]
    for key in ("title", "date", "description", "image", "draft"):
        assert re.search(rf"^{key}:", frontmatter, re.M), (post, key)
    assert not re.search(r"^tags:", frontmatter, re.M), (post, "tags")

all_text = "\n".join(
    p.read_text(encoding="utf-8")
    for p in ROOT.rglob("*")
    if p.is_file() and p.suffix in {".html", ".md", ".toml", ".css", ".txt", ".sh"}
)
assert "published by" not in all_text.lower()
assert ">Tags<" not in all_text
assert 'href="{{ "tags/"' not in all_text
assert "Weather Journal" not in all_text

print(f"OK: {len(posts)} post(s) checked; Greek site name/language are set; tag logic and attribution text are removed; unsafe Markdown HTML remains disabled.")
