#!/usr/bin/env node

const { spawnSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const crdCmd = spawnSync('kubectl', ['get', 'crd', '-A', '-o', 'json'], { encoding: 'utf-8', maxBuffer: 1024 * 8192 })

if (crdCmd.status === 0) {
  JSON.parse(crdCmd.stdout).items.forEach(crd => {
    const filename = `${crd.spec.names.singular}-${crd.spec.group.split('.')[0]}-${crd.spec.versions[0].name}.json`
    console.log(`Writing ${filename}`)
    fs.writeFileSync(path.resolve(__dirname, '../crds/master-standalone', filename), JSON.stringify(crd, null, 2));
  })
} else {
  console.error('ERROR', crdCmd.stderr)
}
