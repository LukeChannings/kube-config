#!/usr/bin/env node

const path = require('path')
const fs = require('fs')
const glob = require('glob')
const yaml = require('yaml')
const colors = require('colors')
const { spawnSync } = require('child_process');

// spawnSync( 'helm', ['dependencies', 'build'])

const helm = spawnSync(
  'helm',
  `install test --dry-run -o json .`.split(' '),
  { encoding: 'utf-8', maxBuffer: 1024 * 8192 }
)

if (helm.status === 0) {
  const { manifest } = JSON.parse(helm.stdout)
  const docs = yaml.parseAllDocuments(manifest)

  try {
    fs.mkdirSync('./helm-manifests')
  } catch (_) {}

  for (const doc of docs) {
    const src = doc.contents.items[0].commentBefore
    fs.writeFileSync('./helm-manifests/' + path.basename(src), '---\n' + yaml.stringify(doc))
  }
} else {
  console.log('Error', helm.stderr)
}
