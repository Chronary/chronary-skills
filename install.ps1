# Chronary skill installer (Windows PowerShell).
#
# Usage:
#   iwr -useb https://raw.githubusercontent.com/Chronary/chronary-skills/main/install.ps1 | iex
#   $env:CHRONARY_INSTALL_TARGET = 'claude-code'; iwr -useb ... | iex
#
# Targets:
#   claude-code | cursor | windsurf | vscode | codex | all (default)

[CmdletBinding()]
param(
  [string]$Target = $(if ($env:CHRONARY_INSTALL_TARGET) { $env:CHRONARY_INSTALL_TARGET } else { 'all' })
)

$ErrorActionPreference = 'Stop'

$RepoUrl = 'https://github.com/Chronary/chronary-skills.git'
$TmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ("chronary-skills-" + [guid]::NewGuid().ToString('N'))

try {
  Write-Host "Cloning chronary-skills..."
  git clone --depth 1 $RepoUrl $TmpDir | Out-Null

  $Src = Join-Path $TmpDir 'skills'

  function Copy-Skills {
    param([string]$Dest)
    if (-not (Test-Path $Dest)) {
      New-Item -ItemType Directory -Force -Path $Dest | Out-Null
    }
    Copy-Item -Path (Join-Path $Src '*') -Destination $Dest -Recurse -Force
    Write-Host "Installed to $Dest"
  }

  function Install-ClaudeCode {
    Copy-Skills -Dest (Join-Path $env:USERPROFILE '.claude\skills')
  }

  function Install-Cursor {
    Copy-Skills -Dest (Join-Path $env:USERPROFILE '.cursor\skills')
  }

  function Install-Windsurf {
    Copy-Skills -Dest (Join-Path $env:USERPROFILE '.windsurf\skills')
  }

  function Install-VSCode {
    Copy-Skills -Dest (Join-Path (Get-Location) '.github\skills')
    Write-Host "  Tip: commit .github/skills so your team picks up the skills."
  }

  function Install-Codex {
    Copy-Skills -Dest (Join-Path $env:USERPROFILE '.codex\skills')
    Write-Host "  Tip: Codex also reads AGENTS.md per-project. Drop one into a project root with:"
    Write-Host "       iwr -useb https://raw.githubusercontent.com/Chronary/chronary-skills/main/AGENTS.md -OutFile \path\to\project\AGENTS.md"
  }

  switch ($Target.ToLower()) {
    'claude-code' { Install-ClaudeCode }
    'claude'      { Install-ClaudeCode }
    'cursor'      { Install-Cursor }
    'windsurf'    { Install-Windsurf }
    'vscode'      { Install-VSCode }
    'copilot'     { Install-VSCode }
    'codex'       { Install-Codex }
    'all' {
      Install-ClaudeCode
      Install-Cursor
      Install-Windsurf
      Install-Codex
    }
    default {
      Write-Host "Unknown target: $Target"
      Write-Host "Targets: claude-code | cursor | windsurf | vscode | codex | all"
      exit 1
    }
  }

  Write-Host ""
  Write-Host "Next step: set CHRONARY_API_KEY and run 'npx -y @chronary/mcp' in your IDE config."
}
finally {
  if (Test-Path $TmpDir) {
    Remove-Item -Path $TmpDir -Recurse -Force -ErrorAction SilentlyContinue
  }
}
