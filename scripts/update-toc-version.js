const fs = require('fs');
const path = require('path');

const version = process.argv[2];
if (!version) {
  console.error('Version argument is required');
  process.exit(1);
}

// Update .toc file
const tocPath = path.join(__dirname, '..', 'GrindCompanion.toc');
let tocContent = fs.readFileSync(tocPath, 'utf8');
tocContent = tocContent.replace(/^## Version: .+$/m, `## Version: ${version}`);
fs.writeFileSync(tocPath, tocContent, 'utf8');
console.log(`Updated GrindCompanion.toc to version ${version}`);

// Update README.md badge (fallback for static badge if needed)
const readmePath = path.join(__dirname, '..', 'README.md');
let readmeContent = fs.readFileSync(readmePath, 'utf8');
// This ensures any static version references are updated
readmeContent = readmeContent.replace(
  /\[!\[Version\]\(https:\/\/img\.shields\.io\/badge\/version-[^-]+-blue\.svg\)\]/,
  `[![Version](https://img.shields.io/github/v/release/anthonygauthier/GrindCompanion?label=version)]`
);
fs.writeFileSync(readmePath, readmeContent, 'utf8');
console.log(`Updated README.md version references`);
