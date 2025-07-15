# SQL Regex Scanner (Cross-Platform)

This repository provides a portable solution to scan `.sql` files in a `.zip` archive
using custom regex rules. Designed to work in Jenkins and GitHub Actions pipelines
on both Linux and Windows agents.

---

## 📁 Project Structure

| File/Folder                | Description |
|---------------------------|-------------|
| `scan_sql.sh`             | Bash script for Linux/macOS to scan `.sql` files using regex rules |
| `scan_sql.ps1`            | PowerShell script for Windows to perform the same scan |
| `rules.txt.example`       | Example rule file with sample regex patterns (one per line, `#` for comments) |
| `.github/workflows/scan.yml` | GitHub Actions workflow for automated scans on push |
| `Jenkinsfile`             | Jenkins pipeline configuration to run scans on agents (Linux or Windows) |

---

## 🔧 Scripts

### `scan_sql.sh`
A portable Bash script to:
- Unzip SQL files
- Apply regex rules from a text file
- Generate a JSON report
- Output matches to the console
- Exit with code `1` if any rule matched

**Inputs:**
- `rules.txt`: Path to file with regex patterns (one per line, `#` for comments)
- `archive.zip`: A `.zip` archive containing `.sql` files (recursively scanned)
- `[output.json]` *(optional)*: Output file for match results (default: `scan_report.json`)

**Outputs:**
- A JSON file listing matched rules with fields: `file`, `line`, `rule`
- Console output for all matches
- Exit code `1` on match, `0` if clean

**Dependencies:**
- `bash`
- `unzip`

Usage:
```bash
./scan_sql.sh rules.txt archive.zip [output.json]
```

---

### `scan_sql.ps1`
A PowerShell equivalent of the Linux script for use on Windows agents.
Uses .NET to unzip the archive and scan SQL files.

**Inputs:**
- `rules.txt`: Path to regex rules
- `archive.zip`: Compressed archive of `.sql` files
- `[output.json]` *(optional)*: Report output file (default: `scan_report.json`)

**Outputs:**
- JSON report with matched rules (`file`, `line`, `rule`)
- Console output with match details
- Exit code `1` if any matches, `0` if clean

**Dependencies:**
- PowerShell 5.0+
- .NET (for `System.IO.Compression.FileSystem`)

Usage:
```powershell
.\scan_sql.ps1 .\rules.txt .\archive.zip [output.json]
```

---

## 🧪 Example Rules (`rules.txt.example`)
```text
# Match wildcard selects
SELECT \*

# Match lines assigning password
password\s*=\s*['"]
```

---

## 🤖 GitHub Actions Workflow — `.github/workflows/scan.yml`
This workflow runs on `push` when SQL archive or rule file changes.
Steps:
- Checkout code
- Run scan on Linux
- Upload report

---

## 🏗️ Jenkinsfile
Pipeline that detects platform and runs correct scan script.
Artifacts are archived and the build fails on rule violations.

---

## ✅ Notes
- Scans are recursive inside `.zip`
- Only `.sql` files are checked
- JSON report includes: file name, line number, rule string
- Console output highlights each match

---

💬 Customize the rule file to meet your policy.
📩 Use this repository as a scanning utilit
