'use strict'
const electron = require('electron')
let chokidar = null;
if (process.env.NODE_ENV == 'development') {
  chokidar = require('chokidar')
}

const app = electron.app
const BrowserWindow = electron.BrowserWindow

let mainWindow // saves a global reference to mainWindow so it doesn't get garbage collected

app.on('ready', createWindow) // called when electron has initialized

// tell chokidar to watch these files for changes
// reload the window if there is one
if (chokidar) {
  chokidar.watch(['ports.js', 'index.html', 'elm.js']).on('change', () => {
      if (mainWindow) {
        mainWindow.reload()
      }
  })
}

// This will create our app window, no surprise there
function createWindow () {
  mainWindow = new BrowserWindow({
    width: 1024, 
    height: 768,
    minWidth: 640,
    minHeight: 480,
  })

  // display the index.html file
  mainWindow.loadURL(`file://${ __dirname }/index.html`)
  
  // open dev tools by default so we can see any console errors
  if (process.env.NODE_ENV == 'development') {
    mainWindow.webContents.openDevTools()
  }

  mainWindow.on('closed', function () {
    mainWindow = null
  })
}

/* Mac Specific things */

// when you close all the windows on a non-mac OS it quits the app
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') { app.quit() }
})

// if there is no mainWindow it creates one (like when you click the dock icon)
app.on('activate', () => {
  if (mainWindow === null) { createWindow() }
})
