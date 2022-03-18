const core = require('@actions/core');
const cache = require('@actions/tool-cache');
const semver = require('semver');
const fs = require('fs').promises;
const os = require('os');

const toolName = 'ize';

async function exec() {
    try {
        let toolPath;
        // const version = core.getInput('version');
        const version = '0.3.0';

        // is this version already in our cache
        toolPath = cache.find(toolName, version);

        if (!toolPath) {
            toolPath = await downloadCLI(version);
        }

        // add tool to path for this and future actions to use
        core.addPath(toolPath);
    } catch (error) {
        core.setFailed(error.message);
    }
}

async function downloadCLI(version) {
    const cleanVersion = semver.clean(version) || '';
    const downloadURL = encodeURI(`https://github.com/hazelops/ize/releases/download/${cleanVersion}/ize_${cleanVersion}_linux_amd64.tar.gz`);
    const downloadedTool = await cache.downloadTool(downloadURL);

    const extractedPath = await cache.extractTar(downloadedTool);
    const toolPath = `${extractedPath}/ize`
    const permissions = 0o755;

    await fs.chmod(toolPath, permissions);

    // const dir = cache.cacheDir(toolPath, toolName, version, os.arch());
    // core.debug(dir)
    // return dir
    return await cache.cacheFile(toolPath, toolName, toolName, version, os.arch());
}

exec();
