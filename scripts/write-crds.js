#!/usr/bin/env node

/**
 * Usage: kubectl get crd -A -o json | ./scripts/write-crds.js
 */

const fs = require('fs');
const path = require('path');

const allCrdsPromise = new Promise((resolve, reject) => {
  let stdin = '';

  process.stdin.setEncoding('utf8');

  process.stdin.on('readable', () => {
    let chunk;
    while ((chunk = process.stdin.read()) !== null) {
      stdin += chunk;
    }
  });

  process.stdin.on('end', () => {
    try {
      resolve(JSON.parse(stdin.trim()));
    } catch (err) {
      reject(new Error("Stdin was no a JSON document! Use `kubectl get crd -A -o json`."))
    }
  });
})

const writeCrd = crd => {
  const filename = `${crd.spec.names.singular}-${crd.spec.group.split('.')[0]}-${crd.spec.versions[0].name}.json`
  fs.writeFileSync(path.resolve(__dirname, '../crds/master-standalone', filename), JSON.stringify(crd, null, 2));
}

allCrdsPromise
  .then(allCrds => allCrds.items.forEach(writeCrd))
  .catch(err => console.error(err))
