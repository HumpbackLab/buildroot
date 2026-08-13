#!/usr/bin/env python3

"""Download the newest PX4 runtime asset published on GitHub Releases."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import sys
import tempfile
import urllib.error
import urllib.request


ASSET_PATTERN = re.compile(r"^px4-[^/]+\.zip$")


def github_request(url, authenticate=True):
    headers = {
        "Accept": "application/vnd.github+json",
        "User-Agent": "buildroot-px4-powerfin",
        "X-GitHub-Api-Version": "2022-11-28",
    }
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("SDK_REPO_TOKEN")
    if authenticate and token:
        headers["Authorization"] = f"Bearer {token}"
    return urllib.request.Request(url, headers=headers)


def find_asset(repository):
    url = f"https://api.github.com/repos/{repository}/releases?per_page=30"
    with urllib.request.urlopen(github_request(url), timeout=30) as response:
        releases = json.load(response)

    for release in releases:
        if release.get("draft"):
            continue
        matches = [
            asset
            for asset in release.get("assets", [])
            if ASSET_PATTERN.fullmatch(asset.get("name", ""))
        ]
        if len(matches) > 1:
            names = ", ".join(asset["name"] for asset in matches)
            raise RuntimeError(
                f"release {release.get('tag_name')} has multiple px4-*.zip assets: {names}"
            )
        if matches:
            return release, matches[0]

    raise RuntimeError(
        f"no non-draft release in {repository} contains a px4-*.zip asset"
    )


def cache_metadata(repository, release, asset):
    return {
        "repository": repository,
        "release": release.get("tag_name"),
        "asset": asset.get("name"),
        "digest": asset.get("digest"),
    }


def cached_asset_matches(output, metadata_path, expected):
    if not output.is_file() or not metadata_path.is_file():
        return False
    try:
        with metadata_path.open(encoding="utf-8") as metadata_file:
            return json.load(metadata_file) == expected
    except (OSError, json.JSONDecodeError):
        return False


def download_asset(asset, output):
    output.parent.mkdir(parents=True, exist_ok=True)

    for attempt in range(1, 4):
        digest = hashlib.sha256()
        temporary = None
        try:
            request = github_request(
                asset["browser_download_url"], authenticate=False
            )
            with urllib.request.urlopen(request, timeout=60) as response:
                with tempfile.NamedTemporaryFile(
                    mode="wb",
                    prefix=f".{output.name}.",
                    dir=output.parent,
                    delete=False,
                ) as destination:
                    temporary = Path(destination.name)
                    while True:
                        chunk = response.read(1024 * 1024)
                        if not chunk:
                            break
                        destination.write(chunk)
                        digest.update(chunk)

            actual_digest = digest.hexdigest()
            expected_digest = asset.get("digest")
            if expected_digest and expected_digest != f"sha256:{actual_digest}":
                raise RuntimeError(
                    f"asset digest mismatch: expected {expected_digest}, "
                    f"calculated sha256:{actual_digest}"
                )
            temporary.replace(output)
            output.chmod(0o644)
            print(f"Downloaded {asset['name']} (sha256: {actual_digest})")
            return
        except (RuntimeError, urllib.error.URLError) as error:
            if attempt == 3:
                raise
            print(f"PX4 asset download attempt {attempt} failed: {error}; retrying")
        finally:
            if temporary and temporary.exists():
                temporary.unlink()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--repository", required=True)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()

    try:
        release, asset = find_asset(args.repository)
        metadata_path = Path(f"{args.output}.release.json")
        expected_metadata = cache_metadata(args.repository, release, asset)
        if cached_asset_matches(args.output, metadata_path, expected_metadata):
            print(f"Using cached PX4 release archive: {args.output}")
            return 0
        print(
            f"Selected PX4 release {release.get('tag_name')} asset {asset['name']}"
        )
        download_asset(asset, args.output)
        with metadata_path.open("w", encoding="utf-8") as metadata_file:
            json.dump(expected_metadata, metadata_file, sort_keys=True)
            metadata_file.write("\n")
    except (RuntimeError, urllib.error.URLError, json.JSONDecodeError) as error:
        print(f"PX4 release download failed: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
