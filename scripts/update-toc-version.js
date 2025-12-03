const fs = require('fs');
const path = require('path');

const version = process.argv[2];
if (!version) {
  console.error('Version argument is required');
  process.exit(1);
}

const tocPath = path.join(__dirname, '..', 'GrindCompanion.toc');
let tocContent = fs.readFileSync(tocPath, 'utf8');

// Update version line
tocContent = tocContent.replace(/^## Version: .+$/m, `## Version: ${version}`);

fs.writeFileSync(tocPath, tocContent, 'utf8');
console.log(`Updated GrindCompanion.toc to version ${version}`);
