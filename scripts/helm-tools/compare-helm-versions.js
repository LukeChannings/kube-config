#!/usr/bin/env node

const fs = require('fs')
const glob = require('glob')
const yaml = require('yaml')
const colors = require('colors')
const { spawnSync } = require('child_process');

const charts = glob.sync('./**/Chart.yaml')

if (charts.length === 0) {
  console.log('No charts found')
}

let results = [
  ['Chart Name', 'Chart Dependency', 'Current Version', 'Latest Version']
]

for (const chart of charts) {
  const chartYaml = fs.readFileSync(chart, { encoding: 'utf-8' })
  const chartParsed = yaml.parse(chartYaml)

  const chartName = chartParsed.name

  if (Array.isArray(chartParsed.dependencies) && chartParsed.dependencies.length !== 0) {
    for (const dependency of chartParsed.dependencies) {
      const helm = spawnSync('helm',  `show chart --repo ${dependency.repository} ${dependency.name}`.split(' '), { encoding: 'utf-8', maxBuffer: 1024 * 8192 })
      if (helm.status === 0) {
        const latestVersion = yaml.parse(helm.stdout).version

        results.push([chartName, dependency.name, dependency.version, latestVersion])
      } else if (helm.stderr) {
        console.error('error', helm.stderr)
      }
    }
  }
}

const table = results
  .flatMap((row, rowIndex, allRows) => {
    let printedRow = `| ${row
      .map((col, colIndex, allCols) => {
        const widestCol = Math.max(...allRows.map(cols => cols[colIndex].length))
        if (colIndex === 3 && rowIndex !== 0) {
          return colors[allCols[2] === allCols[3] ? 'green' : 'red'](col.padEnd(widestCol, ' '))
        }
        return col.padEnd(widestCol, ' ')
      })
      .join('  |  ')} |`

    if (rowIndex === 0) {
      printedRow += '\n' + ('-'.repeat(printedRow.length))
    }
    return printedRow
  })
  .join('\n')

console.log(table)
