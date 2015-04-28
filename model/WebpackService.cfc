component accessors=true {
    property name="Utilities";

    public function getAssetPath(required asset) {
        if (usingWebpackDevServer()) {
            return getPublicPath() & asset;
        } else {
            return getPublicPath() & getManifest()[listFirst(asset, ".")];
        }
    }

    public function getManifest() {
        return deserializeJSON(fileRead(getManifestPath()));
    }

    public function usingWebpackDevServer() {
        return not fileExists(getManifestPath());
    }

    public function getPublicPath() {
        if (usingWebpackDevServer()) {
            return "http://localhost:8080/dist/";
        } else {
            return getUtilities().getPluginPath('/client/dist/');
        }
    }

    public function getManifestPath() {
        return getUtilities().getPluginPath('/client/dist/manifest.json');
    }

}